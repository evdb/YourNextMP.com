#!/usr/bin/env perl

use strict;
use warnings;

use Term::ProgressBar::Simple;

my @files =
  grep { !m{^inc/} }    # not the 'inc' dir
  split /\s+/, `ack --perl -l .`;

my $progress = Term::ProgressBar::Simple->new( scalar @files );

foreach my $file (@files) {

    system("perltidy -b $file");
    unlink "$file.bak";
    $progress++;

}
