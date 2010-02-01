package YourNextMP::Controller::Seats;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

YourNextMP::Controller::Seats - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->can_do_output('json');

    my $seats = $c->db('Seat');

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;

    if ($query) {
        $seats =
            $query =~ m{\d}
          ? $seats->search_postcode($query)
          : $seats->fuzzy_search( { name => $query } );
    }

    $c->stash->{view_all} = $c->req->param('view_all') || 0;
    $c->stash->{query}    = $query;
    $c->stash->{seats}    = $seats;

    # check for JSON output
    if ( $c->output_is('json') ) {

        if ( $query || $c->stash->{view_all} ) {    # FIXME - nasty logic

            $c->stash->{json_result} = $seats->extract_rows(
                {
                    name => '',
                    code => '',
                    url =>
                      sub { $c->uri_for( '/seats', shift()->id )->as_string },
                }
            );
        }
        else {
            $c->stash->{json_result} = [];
        }
    }

}

=head2 seat

=cut

sub view : Path : Args(1) {
    my ( $self, $c, $code ) = @_;

    $c->stash->{seat} = $c->db('Seat')->find({code=>$code})
      || $c->detach('/page_not_found');

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
