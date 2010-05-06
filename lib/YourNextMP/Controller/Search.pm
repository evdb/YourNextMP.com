package YourNextMP::Controller::Search;
use parent qw/Catalyst::Controller/;

use strict;
use warnings;

use List::Util qw( sum first );

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    my $query = $c->req->param('query') || '';
    return unless $query;

    # store query on stash
    $c->stash->{query} = $query;

    # search for the query
    my $seats =
        $query =~ m{\d}
      ? $c->db('Seat')->search_postcode($query)->search( undef, { rows => 5 } )
      : $c->db('Seat')->fuzzy_search( { name => $query } )
      ->search( undef, { rows => 5 } );
    my $parties =
      $c->db('Party')->fuzzy_search( { name => $query } )
      ->search( undef, { rows => 5 } );
    my $candidates =
      $c->db('Candidate')->fuzzy_search( { name => $query } )
      ->search( undef, { rows => 5 } );

    my @rs = ( $seats, $parties, $candidates );

    # check to see if there is only one result
    my $total_count = sum map { $_->count } @rs;

    if ( $total_count == 1 ) {
        my $result = first { $_ } map { $_->first } @rs;
        $c->res->redirect( $c->uri_for( $result->path ) );
        $c->detach;
    }

    $c->stash->{seats}      = $seats;
    $c->stash->{parties}    = $parties;
    $c->stash->{candidates} = $candidates;
}

1;
