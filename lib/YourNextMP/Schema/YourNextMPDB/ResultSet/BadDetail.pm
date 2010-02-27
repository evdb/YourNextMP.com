package YourNextMP::Schema::YourNextMPDB::ResultSet::BadDetail;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use DateTime;

=head2 grab

    $bad_detail = $rs->grab(  );

Grab a bad_detail to correct.

This will up the act_after value by 20 minutes and increment the act_count. It
will also delay other details for the same candidate by 5 minutes so that there
should not be a conflict for the users.

If there are no more bad details due then returns undef.

=cut

sub grab {
    my $rs     = shift;
    my $detail = undef;

    $rs->result_source->schema->txn_do(
        sub {

            # set up some times
            my $now        = DateTime->now;
            my $short_time = $now + DateTime::Duration->new( minutes => 5 );
            my $long_time  = $now + DateTime::Duration->new( minutes => 20 );

            # search for a matching detail
            $detail = $rs->search(    #
                { act_after => { '<=' => $now } },    #
                { rows => 1 }
              )->first
              || return;

            # update this detail so that noone else grabs it
            $detail->update(
                {
                    act_after => $long_time,
                    act_count => $detail->act_count + 1,
                }
            );

            # update the other details for this candidate with a lesser amount
            $detail->others_for_candidate->update(
                { act_after => $short_time } );

            return 1;
        }
    );

    return $detail;
}

1;
