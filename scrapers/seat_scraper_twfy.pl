#!/usr/bin/env perl

use strict;
use warnings;

use lib '../YourNextMP/lib';

use File::Slurp;
use YourNextMP;
use YourNextMP::Util::TheyWorkForYou;
use Encode;

my $rs = YourNextMP->model('Seat');
$rs->delete_all;

my $results = YourNextMP::Util::TheyWorkForYou->new->query(    #
    getSeats => { date => '3 June 2010' }
);
my @names = map { $_->{name} } @$results;

foreach my $name ( sort @names ) {
    my $code = $rs->name_to_code($name);
    print encode_utf8("$name -> $code\n");
    my $cons = $rs->find_or_create( { code => $code, name => $name } );
}

