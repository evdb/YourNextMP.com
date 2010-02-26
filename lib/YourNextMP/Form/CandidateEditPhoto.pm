package YourNextMP::Form::CandidateEditPhoto;

use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has '+enctype' => ( default => 'multipart/form-data' );

has_field 'photo_url' => (
    type  => 'Text',
    label => 'Either photo URL',
    apply => [
        {
            check => sub {
                my $url = shift;
                my $rs  = YourNextMP->db('Image');

                return    # ok if...
                  $rs->find( { source_url => $url } )    # ...image exists
                  || $rs->can_capture_url($url);         # ...or valid to fetch
            },
            message =>
              'Bad url - either url is malformed or not pointing to an image',
        },
    ]
);

has_field 'photo_upload' => (
    type  => 'Upload',
    label => 'Or upload photo',
    apply => [
        {
            check => sub {
                my $upload = shift;
                my $mime   = $upload->type;
                return 1
                  if YourNextMP->db('Image')->is_mime_type_acceptable($mime);
                return;
            },
            message => 'Bad upload - not an image',
        },
    ]
);

has_field 'submit' => ( type => 'Submit' );

sub validate {
    my $form = shift;

    # check that we have either a url or an upload.
    my $url    = $form->field('photo_url')->value;
    my $upload = $form->field('photo_upload')->value;
    unless ( $url || $upload ) {
        $form->field('photo_url')->add_error('Need either an url or an upload');
    }

    1;    # no effect
}

around 'update_model' => sub {
    my $orig      = shift;
    my $form      = shift;
    my $candidate = $form->item;

    my $photo_url    = $form->field('photo_url')->value;
    my $photo_upload = $form->field('photo_upload')->value;

    my $image_rs = YourNextMP->db('Image');

    $form->schema->txn_do(
        sub {

            my $image = undef;

            # If there was a photo try to use that
            if ($photo_upload) {
                $image = $image_rs->create( { upload => $photo_upload } );
            }
            elsif ($photo_url) {
                $image =
                  $image_rs->find_or_create( { source_url => $photo_url } );
            }

            # No image we can't go on
            return unless $image;

            # Add image to candidate if required
            $candidate->update( { image_id => $image->id } )
              unless $candidate->image_id    #
                  && $candidate->image_id == $image->id

        }
    );
};

no HTML::FormHandler::Moose;

1;
