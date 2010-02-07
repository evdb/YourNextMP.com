#!/usr/bin/perl -w

use strict;
use Test::More tests => 2;

use YourNextMP;

is(
    YourNextMP->config->{general_test_key},    #
    'general_test_value',                      #
    "main config loaded"
);

is(
    YourNextMP->config->{local_test_key},      #
    'local_test_value',                        #
    "config loaded"
);
