#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 15;

use YourNextMP;

# create a new candidate
my $candidate = YourNextMP->db('Candidate')->find_or_create(
    {
        name => 'Joe Test',
        party_id =>
          YourNextMP->db('Party')->find( { code => 'independent' } )->id,
    }
);
ok $candidate, "Got a candidate";

# check that the correct entries are in the bad_details table
is $candidate->bad_details->count, 4, "got all bad details";
is $_->issue, 'missing', "issue is 'missing' for " . $_->detail
  for $candidate->bad_details->all;

# update the candidate
ok $candidate->update(
    {
        email   => 'fozzy@bear.com',
        phone   => '020 8123 4567',
        fax     => '020 8123 4568',
        address => 'The Woods, Bearville, W12 3AB',
    }
  ),
  "updated candidate with good details";

# check bad_details again
is $candidate->bad_details->count, 0, "got no bad details";

# give the candidate HoP details
ok $candidate->update(
    {
        email   => 'fozzyb@parliament.uk',
        phone   => '020 7219 8400',
        fax     => '020 7219 2043',
        address => 'House of Commons, London, SW1A 0AA',
    }
  ),
  "updated candidate with good details";

# check that the issue is now 'parliament' for the details
is $candidate->bad_details->count, 4, "got all bad details";
is $_->issue, 'parliament', "issue is 'parliament' for " . $_->detail
  for $candidate->bad_details->all;

# delete the candidate
ok $candidate->delete, "delete the candidate";

# check they are gone
