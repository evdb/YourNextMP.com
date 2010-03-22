package YourNextMP::Controller::Parties;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

sub result_base : PathPart('parties') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Party';
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

1;
