package YourNextMP::Controller::DemocracyClub;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

use YourNextMP::Form::CandidateEditBadDetails;

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->require_user('Please log in to access this section of the site');
    return 1;
}

sub bad_details : Local {
    my ( $self, $c ) = @_;

    $c->forward('get_bad_detail');
    $c->forward('prepare_bad_detail_form');
    $c->forward('process_bad_detail_form');

    return 1;
}

sub get_bad_detail : Private {
    my ( $self, $c ) = @_;

    # get the bad detail to work on
    my $bad_detail    #
      = $c->forward('get_existing_bad_detail')
      || $c->forward('get_new_bad_detail');

    # bail out if there are no more details to do
    if ( !$bad_detail ) {
        $c->stash->{template} = 'democracyclub/no_more_bad_details.html';
        $c->detach;
    }

    $c->stash(
        bad_detail => $bad_detail,
        candidate  => $bad_detail->candidate
    );

    return $bad_detail;
}

sub get_new_bad_detail : Private {
    my ( $self, $c ) = @_;

    # get the bad detail to work on
    return $c              #
      ->db('BadDetail')    #
      ->search( undef, { prefetch => 'candidate' } )    #
      ->grab;

}

sub get_existing_bad_detail : Private {
    my ( $self, $c ) = @_;

    my $id = $c->req->param('bad_detail_id') || '';     #
    $id =~ s{\D+}{}g;

    return unless $id;

    # get the bad detail to work on
    return $c                                           #
      ->db('BadDetail')                                 #
      ->find($id);
}

sub prepare_bad_detail_form : Private {
    my ( $self, $c ) = @_;

    my $bad_detail = $c->stash->{bad_detail};

    # Get the form
    my $form =
      YourNextMP::Form::CandidateEditBadDetails->new(
        item => $bad_detail->candidate );

    # Add in the bad_detail_id
    $form->field('bad_detail_id')->value( $bad_detail->id );

    # hide all the fields apart from the detail we want
    foreach my $detail (qw( email phone fax address )) {
        my $field = $form->field($detail);

        if ( $detail eq $bad_detail->detail ) {
            $field->required(1);
        }
        else {
            $field->inactive(1);
        }
    }

    $c->stash( form => $form );

    return $form;
}

sub process_bad_detail_form : Private {
    my ( $self, $c ) = @_;
    my $bad_detail = $c->stash->{bad_detail};
    my $form       = $c->stash->{form};

    return unless $c->req->method eq 'POST';
    return unless $form->process( params => $c->req->body_parameters );

    $c->forward('bad_detail_succesfully_updated');
}

sub bad_detail_succesfully_updated : Private {
    my ( $self, $c ) = @_;

    # Form was good - redirect back to ourselves to pick up a new bad_detail to
    # process
    $c->res->redirect( $c->uri_for( '/' . $c->req->action ) );
    $c->detach;
}

1;
