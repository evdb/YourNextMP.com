#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;

my $party_rs = YourNextMP->model('Party');

# Scrape all the parties to make sure that the lists are up-to-date
my $parties = $party_rs->search();

while ( my $party = $parties->next ) {
    printf "Scraping candidate list from %s\n", $party->name;
    $party->scrape_candidates;
}
