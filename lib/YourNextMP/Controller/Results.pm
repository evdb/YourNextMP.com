package YourNextMP::Controller::Results;
use parent qw/Catalyst::Controller/;

use strict;
use warnings;
use Sort::Key qw(rikeysort);
use List::Util qw(sum);

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('generate_declared_constituencies');
    $c->forward('generate_election_results');
    $c->forward('generate_recent_seats');
}

sub clear_cache : Private {
    my ( $self, $c ) = @_;
    $c->cache->remove($_)
      for qw(recent_seats declared_constituencies election_results);
}

sub generate_recent_seats : Private {
    my ( $self, $c ) = @_;

    $c->stash->{recent_seats} = $c->smart_cache(
        {
            key         => 'recent_seats',
            expires     => 600,
            ignore_user => 1,
            code        => sub {
                my $seats_rs = $c->db('Seat')    #
                  ->search(                      #
                    { votes_recorded => 1 },
                    {
                        order_by => 'votes_recorded_when desc',
                        rows     => 5,
                    }
                  );

                my @recent_seats = ();

                while ( my $seat = $seats_rs->next ) {
                    my $winner = $seat->winner;
                    push @recent_seats,
                      {
                        name            => $seat->name,
                        total_votes     => $seat->total_votes,
                        winner_image_id => $winner->image_id,
                        winner_name     => $winner->name,
                        winner_party    => $winner->party->name,
                        winner_votes    => $winner->votes,
                      };
                }

                return \@recent_seats;
            },
        }
    );

}

sub generate_declared_constituencies : Private {
    my ( $self, $c ) = @_;

    $c->stash->{declared_constituencies} = $c->smart_cache(
        {
            key         => 'declared_constituencies',
            expires     => 600,
            ignore_user => 1,
            code        => sub {
                my $seats_rs = $c->db('Seat');
                my $declared =
                  $seats_rs->search( { votes_recorded => 1 } )->count;
                my $pending = $seats_rs->count - $declared;
                return {
                    declared => $declared,
                    pending  => $pending
                };
            },
        }
    );

}

sub generate_election_results : Private {
    my ( $self, $c ) = @_;

    $c->stash->{election_results} = $c->smart_cache(
        {
            key         => 'election_results',
            expires     => 600,
            ignore_user => 1,
            code        => sub {
                my $seats_rs = $c->db('Seat');

                # go through all the seats and count the number for each party
                my %party_seats = ();
                my %party_votes = ();
                my $total_votes = 0;

                # Extract all the winning parties
                my $declared_seats =
                  $seats_rs->search( { votes_recorded => 1 } );

                while ( my $seat = $declared_seats->next ) {
                    my $winner = $seat->winner || next;
                    my $party_name = $winner->party->name;
                    $party_seats{$party_name}++;
                }

                # create the arrays for the seats
                my @seat_labels =
                  rikeysort { $party_seats{$_} } sort keys %party_seats;
                my @seat_data = map { $party_seats{$_} } @seat_labels;
                @seat_labels = map { "$_ ($party_seats{$_})" } @seat_labels;

                # get sums of all the votes by party
                my $votes_rs = $c->db('Candidate')    #
                  ->standing                          #
                  ->search(
                    { votes => { '>' => 0 } },
                    {
                        join    => 'party',
                        columns => {
                            party_name => 'party.name',
                            votes      => \'sum(votes)',
                        },
                        group_by => ['party.name'],
                        order_by => undef,
                    }
                  );

                while ( my $row = $votes_rs->next ) {
                    my $party_name = $row->get_column('party_name');
                    my $votes      = $row->get_column('votes');
                    $party_votes{$party_name} = $votes;
                    $total_votes += $votes;
                }

                # create the arrays for the seats
                my @vote_labels =
                  rikeysort { $party_votes{$_} } sort keys %party_votes;
                my @vote_data = map { $party_votes{$_} } @vote_labels;
                @vote_labels = map { "$_ ($party_votes{$_})" } @vote_labels;

                # But we only want to show the top parties
                my $cutoff = 10;
                if ( @vote_labels > $cutoff ) {
                    splice @vote_labels, $cutoff;

                    my $other_votes = sum splice @vote_data, $cutoff;
                    push @vote_data,   $other_votes;
                    push @vote_labels, "Other ($other_votes)";
                }

                return {
                    party_seats => \%party_seats,
                    seat_data   => \@seat_data,
                    seat_labels => \@seat_labels,

                    party_votes => \%party_votes,
                    vote_data   => \@vote_data,
                    vote_labels => \@vote_labels,

                    total_votes => $total_votes,
                    vote_cutoff => $cutoff,
                };
            },
        }
    );

}

1;
