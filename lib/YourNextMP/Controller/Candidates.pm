package YourNextMP::Controller::Candidates;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

sub result_base : PathPart('candidates') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Candidate';
}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    my $results = $c->db( $self->source_name );

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;

    if ($query) {
        $results =
            $query =~ m{\d}
          ? $results->search_postcode($query)
          : $results->fuzzy_search( { name => $query } );
    }

    $c->stash->{view_all} = $c->req->param('view_all') || 0;
    $c->stash->{query}    = $query;
    $c->stash->{results}  = $results;

}

1;
