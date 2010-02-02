#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP::Schema::YourNextMPDB;

my $candidate_rs = YourNextMP::Schema::YourNextMPDB->resultset('Candidate');

# get all the candidates that need scraping
my $to_scrape =
  $candidate_rs->search( { scrape_source => { like => 'http://%' } } );

while ( my $candidate = $to_scrape->next ) {
    printf "Scraping %s (%s)...\n", $candidate->name, $candidate->party->name;

    $candidate->update_by_scraping;
}
