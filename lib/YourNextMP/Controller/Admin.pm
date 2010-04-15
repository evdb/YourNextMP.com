package YourNextMP::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->require_admin_user("Log in as an admin user to access admin section");

    return 1;
}

sub index : Path('') {
    my ( $self, $c ) = @_;

    # passthrough
}

sub duplicate_candidates : Local {
    my ( $self, $c ) = @_;

    my @seats_with_duplicates = ();
    my $all_seats             = $c->db('Seat');
    my @party_ids_to_ignore =
      map { $c->db('Party')->find( { code => $_ } )->id } qw(independent);

    while ( my $seat = $all_seats->next ) {

        # count the occurences of the parties
        my %party_counts = ();
        $party_counts{$_}++
          for map { $_->party_id } $seat->candidates->standing;

        # delete the independents etc.
        delete $party_counts{$_} for @party_ids_to_ignore;

        # skip on unless there are duplicates
        next unless grep { $_ > 1 } values %party_counts;

        push @seats_with_duplicates, $seat;
    }

    $c->stash->{seats_with_duplicates} = \@seats_with_duplicates;

}

1;
