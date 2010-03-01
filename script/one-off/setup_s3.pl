#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';

use YourNextMP;

my $client = YourNextMP->s3_client;

print "creating public bucket\n";
$client->create_bucket(
    name                => YourNextMP->config->{aws}{public_bucket_name},
    acl_short           => 'public-read',
    location_constraint => 'EU',
);

print "creating private bucket\n";
$client->create_bucket(
    name                => YourNextMP->config->{aws}{private_bucket_name},
    acl_short           => 'private',
    location_constraint => 'EU',
);
