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

sub search_for_results : Private {
    my ( $self, $seats, $query, $c ) = @_;
    if ( $query =~ m{\d} ) {
        $c->flash->{searched_by_postcode} = 1;
        return $seats->search_postcode($query);
    }
    else {
        return $seats->fuzzy_search( { name => $query } );
    }
}

sub view : PathPart('') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{candidates} = $c->stash->{result}->candidates->standing;

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
