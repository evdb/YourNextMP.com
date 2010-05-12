package YourNextMP::Controller::Results;
use parent qw/Catalyst::Controller/;

use strict;
use warnings;
use Sort::Key qw(rikeysort);
use List::Util qw(sum);
use LWP::UserAgent;

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('generate_declared_constituencies');
    $c->forward('generate_election_results');
    $c->forward('generate_recent_seats');
}

sub clear_cache : Private {
    my ( $self, $c ) = @_;
    $c->cache->remove($_)
      for (
        'recent_seats', 'declared_constituencies', 'election_results',    #
        'seat_pie_chart', 'vote_pie_chart',
      );
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

                    my $winner_data = undef;
                    if ( my $winner = $seat->winner ) {
                        $winner_data = {
                            image_id => $winner->image_id,
                            name     => $winner->name,
                            party    => $winner->party->name,
                            votes    => $winner->votes,
                        };
                    }

                    push @recent_seats,
                      {
                        name        => $seat->name,
                        path        => $seat->path,
                        total_votes => $seat->total_votes,
                        winner      => $winner_data,
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

sub add_missing : Local {
    my ( $self, $c ) = @_;

    # Find how many constituencies which there are no votes for yet
    my $not_entered_rs =
      $c->db('Seat')->search( { votes_recorded_when => undef }, );

    my $count = $not_entered_rs->count;

    # are we all done - send to results page with a message
    if ( $count <= 1 ) {    # FIXME - hack for delayed seat
        $c->flash->{message} =
          "Results have been entered for all constituencies.";
        $c->res->redirect( $c->uri_for('/results') );
        return;
    }

    # pick a random seat
    my $seat = $not_entered_rs->search(
        undef,
        {
            rows   => 1,
            offset => int( rand $count ),
        }
    )->first;

    # redirect to it
    $c->res->redirect( $c->uri_for( $seat->path, 'record_votes' ) );
    return;
}

sub seat_pie_chart : Local {
    my ( $self, $c ) = @_;

    my $content = $c->smart_cache(
        {
            key         => 'seat_pie_chart',
            expires     => 600,
            ignore_user => 1,
            code        => sub {

                $c->forward('generate_election_results');
                my $election_results = $c->stash->{election_results};

                my $args = {
                    chd => 't:'
                      . join( ',', @{ $election_results->{seat_data} } ),
                    chl  => join( '|', @{ $election_results->{seat_labels} } ),
                    chds => '0,650',
                    chco => 'FF9900',
                };

                return get_pie_chart($args);
            },
        }
    );

    $c->res->content_type('image/png');
    $c->res->body($content);

}

sub vote_pie_chart : Local {
    my ( $self, $c ) = @_;

    my $content = $c->smart_cache(
        {
            key         => 'seat_pie_chart',
            expires     => 600,
            ignore_user => 1,
            code        => sub {

                $c->forward('generate_election_results');
                my $election_results = $c->stash->{election_results};

                my $args = {
                    chd => 't:'
                      . join( ',', @{ $election_results->{vote_data} } ),
                    chl => join( '|', @{ $election_results->{vote_labels} } ),
                    chds => '0,' . $election_results->{total_votes},
                    chco => '5F8FC8',
                };

                return get_pie_chart($args);
            },
        }
    );

    $c->res->content_type('image/png');
    $c->res->body($content);

}

sub get_pie_chart {
    my $args = shift;

    my $post_args = {
        cht => 'p',
        chs => '800x250',
        %$args,
    };

    my $ua = LWP::UserAgent->new;
    my $res = $ua->post( 'http://chart.apis.google.com/chart', $post_args );

    return $res->content;
}

1;
