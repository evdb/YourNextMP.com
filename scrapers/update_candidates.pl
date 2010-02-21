#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;
use DateTime;

my $candidate_rs = YourNextMP->model('Candidate');
my $scraped_before = DateTime->now - DateTime::Duration->new( hours => 20 );

# get all the candidates that need scraping
my $to_scrape = $candidate_rs->search(
    {
        can_scrape    => 1,                         #
        scrape_source => { like => 'http://%' },    #
        last_scraped  => [
            { '<'  => $scraped_before },            # not scraped recently
            { 'is' => undef }                       # or not scraped at all
        ],
    }
);

while ( my $candidate = $to_scrape->next ) {
    printf "Scraping %s (%s)...\n", $candidate->name, $candidate->party->name;
    eval { $candidate->update_by_scraping };
    warn $@ if $@;
}
