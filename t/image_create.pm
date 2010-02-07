#!/usr/bin/perl -w

use strict;
use Test::More tests => 10;

use YourNextMP::Schema::YourNextMPDB;

my $image_rs = YourNextMP->model('Image');

my $url = 'http://farm1.static.flickr.com/85/233472093_1f1d235e7b_d.jpg';

$image_rs->search( { source_url => $url } )->delete;
my $image = $image_rs->create( { source_url => $url } );

ok $image, "Created a new image";

my @paths = ();

for (qw(original small medium large)) {
    my $path = $image->full_path_to_image($_);
    ok -e $path, "Found $_: $path";
    push @paths, $path;
}

ok $image->delete, "delete image";

ok( !-e $_, "file now deleted: $_" ) for @paths;
