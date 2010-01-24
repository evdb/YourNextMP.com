package YourNextMP::Controller::Candidates;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $candidates     #
      = $c             #
      ->model('DB')    #
      ->resultset('Candidates');

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;

    if ($query) {
        $candidates =
            $query =~ m{\d}
          ? $candidates->search_postcode($query)
          : $candidates->fuzzy_search( { name => $query } );
    }

    $c->stash->{view_all}   = $c->req->param('view_all') || 0;
    $c->stash->{query}      = $query;
    $c->stash->{candidates} = $candidates;

}

sub view : Path : Args(1) {
    my ( $self, $c, $code ) = @_;

    $c->stash->{candidate}         #
      = $c                         #
      ->model('DB')                #
      ->resultset('Candidates')    #
      ->find($code)
      || $c->detach('/page_not_found');

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
