#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use YourNextMP::Util::TheyWorkForYou;
use utf8;
use Encode;

my $twfy = YourNextMP::Util::TheyWorkForYou->new;

# search for a unicode seat
my $result = $twfy->query( getConstituencies => { search => 'ynys' } );
is $result->[0]->{name}, encode_utf8('Ynys Môn'), "Got correct name";

