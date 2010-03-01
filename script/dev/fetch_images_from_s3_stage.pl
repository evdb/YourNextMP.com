#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use Path::Class;
use LWP::Simple;
my $bucket   = YourNextMP->s3_bucket('yournextmp-stage');
my $ynmp_dir = dir('/Users/evdb/yournextmp');

my $stream = $bucket->list( { prefix => 'images/' } );

until ( $stream->is_done ) {

    foreach my $object ( $stream->items ) {
        my $key = $object->key;
        next if $key =~ m{original};

        printf "Looking at %s\n", $key;
        my $file = $ynmp_dir->file($key);
        next if -f $file;

        my $url = 'http://yournextmp-stage.s3.amazonaws.com/' . $key;
        printf "\tfetching %s\n", $url;
        getstore( $url, "$file" );
    }

}

