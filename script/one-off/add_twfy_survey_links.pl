#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;

my @seats = YourNextMP->db('Seat')->all;

foreach my $seat (@seats) {

    my $url = 'http://election.theyworkforyou.com/survey/seats/' . $seat->code;

    # have a url from form - find or create the link
    my $link =
      YourNextMP->db('Link')
      ->find_or_create(
        { url => $url, title => 'TheyWorkForYou Candidate Survey' } );

    # make sure that the link is attached to our result
    $link->find_or_create_related(
        link_relations => {
            foreign_id    => $seat->id,
            foreign_table => $seat->table
        }
    );
}
