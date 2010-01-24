#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use YourNextMP::Util::TheyWorkForYou;
use utf8;

my $twfy = YourNextMP::Util::TheyWorkForYou->new;

# search for a unicode seat
my $result = $twfy->query( getConstituencies => { search => 'ynys' } );
is $result->[0]->{name}, 'Ynys Môn', "Got correct name";

