#!/usr/bin/perl -w

use strict;
use warnings;

use utf8;

use Test::More;
use YourNextMP;

my %tests = (

    Candidate => [
        [ 'Andrew Tyrie MP',       'Andrew Tyrie',    'andrew_tyrie', ],
        [ 'Andy Stranack',         'Andy Stranack',   'andy_stranack', ],
        [ 'Chris Chope OBE MP',    'Chris Chope',     'chris_chope', ],
        [ 'Cllr Jeremy Lefroy',    'Jeremy Lefroy',   'jeremy_lefroy', ],
        [ 'Desmond Swayne TD MP',  'Desmond Swayne',  'desmond_swayne', ],
        [ 'Dominic Grieve QC MP',  'Dominic Grieve',  'dominic_grieve', ],
        [ 'Dr Andrew Murrison MP', 'Andrew Murrison', 'andrew_murrison', ],
        [ 'Dr Phillip Lee',        'Phillip Lee',     'phillip_lee', ],
        [ 'Dr. Julian Huppert',    'Julian Huppert',  'julian_huppert', ],
        [ 'Rt Hon Sir George Young Bt MP', 'George Young', 'george_young', ],
    ],

    Party => [

        [
            'Action To Save St.John\'s Hospital',
            'Action To Save St.John\'s Hospital',
            'action_to_save_st_johns_hospital'
        ],
        [ 'Albion Party',         'Albion Party',   'albion' ],
        [ 'Birthday Party [The]', 'Birthday Party', 'birthday' ],
        [ 'Sinn Féin',           'Sinn Féin',     'sinn_fein' ],
    ],

);

use List::Util 'sum';
plan tests => 2 * sum map { scalar @$_ } values %tests;

foreach my $model ( keys %tests ) {

    my $rs    = YourNextMP->model($model);
    my $names = $tests{$model};

    foreach my $line (@$names) {
        my ( $input, $name, $code ) = @$line;
        is $rs->clean_name($input),   $name, "$input -> $name";
        is $rs->name_to_code($input), $code, "$input -> $code";
    }
}
