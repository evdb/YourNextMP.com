#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use Term::ProgressBar::Simple;

my $candidates = YourNextMP->db('Candidate')->search;

my $progress = Term::ProgressBar::Simple->new( $candidates->count );

while ( my $c = $candidates->next ) {
    $progress++;
    $c->update_bad_details;
}
