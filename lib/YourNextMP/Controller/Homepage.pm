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

                    candidates => $c->db('Candidacy')->search(
                        undef,                            #
                        {
                            select   => 'candidate_id',    #
                            distinct => 1
                        }
                      )->count,

                };
            },
        }
    );

    $c->stash->{top_parties} = $c->smart_cache(
        {
            key     => 'home_page_top_parties',
            expires => 600,
            code    => sub {
                my $rs = $c->db('Party')->search(
                    undef,    #
                    {
                        join   => 'candidates',
                        select => [
                            'me.code',    #
                            'me.name',    #
                            { count => 'candidates.id' }
                        ],
                        as       => [qw( code name candidate_count )],
                        group_by => [ 'me.code', 'me.name' ],

                        order_by => 'count desc, me.code',
                        rows     => 15,
                    }
                );

                return [
                    map {
                        { $_->get_columns }
                      } $rs->all
                ];
            },
        }
    );

}

1;
