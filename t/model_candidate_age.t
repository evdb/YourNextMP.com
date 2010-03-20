#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 8;
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
END { ok $candidate->delete, "delete the candidate"; }

my $ref_dt = DateTime->new( year => 2010, month => 5, day => 6 );    # GE2010

# no dob
ok $candidate->update( { dob => undef } ), "dob: undef";
is $candidate->age, undef, "undef for no dob";

# year only
ok $candidate->update( { dob => '1977' } ), "dob: 1977";
is $candidate->age, "32 or 33 years old (born 1977)",
  "32 or 33 years old (born 1977)";

# full dob
ok $candidate->update( { dob => '31/10/1977' } ), "dob: 31/10/1977";
is $candidate->age, "32 years old (born 31/10/1977)",
  "32 years old (born 31/10/1977)";
