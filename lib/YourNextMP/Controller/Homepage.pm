package YourNextMP::Controller::Homepage;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

__PACKAGE__->config->{namespace} = '';

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{counts} = $c->smart_cache(
        {
            key     => 'home_page_item_counts',
            expires => 600,
            code    => sub {
                return {

                    all_parties    => $c->db('Party')->count,
                    all_seats      => $c->db('Seat')->count,
                    all_candidates => $c->db('Candidate')->count,

                    # select count( DISTINCT party_id)
                    #     from candidates, candidacies
                    #     where candidates.id = candidacies.candidate_id;
                    parties => $c->db('Candidate')    #
                      ->search(
                        undef,
                        {
                            select   => 'me.party_id',    #
                            distinct => 1,
                            join     => 'candidacies',
                            order_by => '',
                        }
                      )                                   #
                      ->count,

                    seats => $c->db('Candidacy')->search(
                        undef,                            #
                        {
                            select   => 'seat_id',        #
                            distinct => 1
                        }
                      )->count,

                    candidates => $c->db('Candidate')->standing->count,

                };
            },
        }
    );

    $c->stash->{top_parties} = $c->smart_cache(
        {
            key     => 'parties_with_candidates',
            expires => 600,
            code    => sub {
                $c->db('Party')->parties_with_candidates_as_arrayref;
            },
        }
    );

    $c->stash->{nominations} = $c->smart_cache(
        {
            key     => 'nominated_constituencies',
            expires => 600,
            code    => sub {
                my $seats_rs = $c->db('Seat');
                my $done =
                  $seats_rs->search( { nominations_entered => 1 } )->count;
                my $pending = $seats_rs->count - $done;
                return {
                    done    => $done,
                    pending => $pending
                };
            },
        }
    );

}

1;
