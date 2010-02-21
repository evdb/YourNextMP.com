package YourNextMP::Form::CandidateEditDetails;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has_field 'email' => (
    type  => 'Email',
    label => 'Email',
);

has_field 'phone' => (
    type  => 'Text',
    label => 'Phone',
);

has_field 'fax' => (
    type  => 'Text',
    label => 'Fax',
);

has_field 'address' => (
    type  => 'TextArea',
    label => 'Postal address',
    cols  => 60,
    rows  => 4,
);

has_field 'photo_url' => (
    type  => 'Text',
    label => 'URL to photograph',
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

has_field 'submit' => ( type => 'Submit' );

around 'update_model' => sub {
    my $orig = shift;
    my $self = shift;
    my $item = $self->item;

    $self->schema->txn_do(
        sub {

            # update the candidate with most details
            $orig->( $self, @_ );

            # If there was a photo try to use that
            if ( my $photo_url = $self->field('photo_url')->value ) {
                my $image =
                  YourNextMP->db('Image')
                  ->find_or_create( { source_url => $photo_url } );

                # Add image to candidate if required
                $item->update( { image_id => $image->id } )
                  unless $item->image_id
                      && $item->image_id == $image->id;
            }
        }
    );
};

no HTML::FormHandler::Moose;

1;
