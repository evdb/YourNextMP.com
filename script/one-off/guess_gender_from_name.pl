#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use Text::GenderFromName;

my $genderless_candidates =
  YourNextMP->db('Candidate')->search( { gender => undef } );

my %seen_names = ();

while ( my $cand = $genderless_candidates->next ) {
    my ($first_name) = $cand->name =~ m{^(\S+)};

    next if !$first_name;
    my $seen_before = $seen_names{$first_name}++;

    # use strictness '2' which seems best
    my $gender = gender( $first_name, 2 ) || '';
    next if !$gender;

    $gender =
        $gender eq 'm' ? 'male'
      : $gender eq 'f' ? 'female'
      :                  die "Unknown gender '$gender'";

    printf "%30s is %s\n", $first_name, $gender unless $seen_before;

    $cand->update( { gender => $gender } );
}
