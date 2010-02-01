#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

# YourNextMP::Schema::YourNextMPLoader

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

make_schema_at(
    'YourNextMP::Schema::YourNextMPDB',
    {
        debug          => 1,
        dump_directory => './lib',
        use_namespaces => 1,
        naming         => 'v5',

        components => [
            '+YourNextMP::Schema::YourNextMPDB::Base::Component',
            'InflateColumn::DateTime'
        ],
    },
    ["dbi:Pg:dbname=yournextmp"]
);
