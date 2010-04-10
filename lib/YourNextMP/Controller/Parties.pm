package YourNextMP::Controller::Parties;
use parent 'YourNextMP::ControllerBase';

use strict;
use warnings;

use YourNextMP::Form::EditPhoto;

sub result_base : PathPart('parties') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Party';
}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{results} = $c->smart_cache(
        {
            key     => 'parties_with_candidates',
            expires => 600,
            code    => sub {
                $c->db('Party')->parties_with_candidates_as_arrayref;
            },
        }
    );
}

sub view : PathPart('') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{candidates} = $c->stash->{result}->candidates->standing;
}

sub candidates_empty : PathPart('candidates') Chained('result_find') {
    my ( $self, $c ) = @_;

    $c->res->redirect(
        $c->uri_for( $c->stash->{result}->code, 'candidates', 1 ) );
    $c->detach;
}

sub candidates : PathPart('candidates') Chained('result_find') Args(1) {
    my ( $self, $c, $page_number ) = @_;

    my $results_per_page = 50;

    # clean up the page_number
    $page_number =~ s{\D+}{}g;
    $page_number ||= 1;

    my $results = $c->stash->{result}->candidates->standing->search(
        undef,    # find everything
        {
            rows => $results_per_page,
            page => $page_number,
        }
    );

    # check that we have not gone beyond the end of the list
    if ( $page_number > $results->pager->last_page ) {
        $c->res->redirect( $c->uri_for( 'all', $results->pager->last_page ) );
        $c->detach;
    }

    $c->stash->{pager}   = $results->pager;
    $c->stash->{results} = $results;
}

sub edit_photo : PathPart('edit_photo') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_admin_user("Please log in as admin to edit party photo");

    # create the form and place it on the stash
    my $party = $c->stash->{result};
    my $form = YourNextMP::Form::EditPhoto->new( item => $party );
    $c->stash( form => $form );

    # If it is not a post then return
    return unless $c->req->method eq 'POST';

    # gather all the parameters - including the uploaded file if posted
    my $params = $c->req->params;
    my $upload = $c->req->upload('photo_upload');
    $params->{photo_upload} = $upload if $upload;

    # process the form and return if there were errors
    return if !$form->process( params => $params );

    # We have a new photo
    $c->res->redirect( $c->uri_for( $party->path ) );
    $c->detach;

}

1;
