#!/usr/bin/perl -w

use strict;
use Test::More tests => 20;

use YourNextMP;

my @names = (
    [ 'Andrew Tyrie MP',          'Andrew Tyrie',      'andrew_tyrie', ],
    [ 'Andy Stranack',            'Andy Stranack',     'andy_stranack', ],
    [ 'Christopher Chope OBE MP', 'Christopher Chope', 'christopher_chope', ],
    [ 'Cllr Jeremy Lefroy',       'Jeremy Lefroy',     'jeremy_lefroy', ],
    [ 'Desmond Swayne TD MP',     'Desmond Swayne',    'desmond_swayne', ],
    [ 'Dominic Grieve QC MP',     'Dominic Grieve',    'dominic_grieve', ],
    [ 'Dr Andrew Murrison MP',    'Andrew Murrison',   'andrew_murrison', ],
    [ 'Dr Phillip Lee',           'Phillip Lee',       'phillip_lee', ],
    [ 'Dr. Julian Huppert',       'Julian Huppert',    'julian_huppert', ],
    [ 'Rt Hon Sir George Young Bt MP', 'George Young', 'george_young', ],
);

my $rs = YourNextMP->model('Candidate');

foreach my $line (@names) {
    my ( $input, $name, $code ) = @$line;

    is $rs->clean_name($input),   $name, "$input -> $name";
    is $rs->name_to_code($input), $code, "$input -> $code";
}
