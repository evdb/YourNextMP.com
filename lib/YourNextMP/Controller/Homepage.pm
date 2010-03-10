package YourNextMP::Controller::Homepage;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

__PACKAGE__->config->{namespace} = '';

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{counts} = $c->get_or_set(
        'home_page_item_counts',
        sub {
            return {
                seats      => $c->db('Seat')->search()->count,
                parties    => $c->db('Party')->search()->count,
                candidates => $c->db('Candidate')->search()->count,
            };
        },
        600
    );

    $c->stash->{top_parties} = $c->get_or_set(
        'home_page_top_parties',
        sub {
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
        600
    );

}

1;
