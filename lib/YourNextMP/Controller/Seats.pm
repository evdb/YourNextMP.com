package YourNextMP::Controller::Seats;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

sub result_base : PathPart('seats') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Seat';
}

sub index : PathPart('') Chained('result_base') Args(0) {
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
    $c->stash->{results}    = $seats;

    # check for JSON output
    if ( $c->output_is('json') ) {

        if ( $query || $c->stash->{view_all} ) {    # FIXME - nasty logic

            $c->stash->{json_result} = $seats->extract_rows(
                {
                    name => '',
                    code => '',
                    url =>
                      sub { $c->uri_for( '/seats', shift()->code )->as_string },
                }
            );
        }
        else {
            $c->stash->{json_result} = [];
        }
    }

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
