#!/usr/bin/perl -w

use strict;
use Test::More tests => 2;
use YourNextMP::Util::TheyWorkForYou;
use utf8;
use Encode;

my $twfy = YourNextMP::Util::TheyWorkForYou->new;

# search for a unicode seat
{
    my $result = $twfy->query( getConstituencies => { search => 'ynys' } );
    is $result->[0]->{name}, 'Ynys Môn', "Got correct name";
}

{
    my $result = $twfy->query(
        getConstituency => { postcode => 'SA19 8BA', future => 1 } );
    is $result->{name}, 'Carmarthen East and Dinefwr',
      "Got correct name for postcode";
}
