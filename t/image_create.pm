#!/usr/bin/perl -w

use strict;
use Test::More tests => 10;

use YourNextMP;

my $image_rs = YourNextMP->model('Image');

# check that non-image files don't crash the code
my $bad_url  = 'http://www.google.co.uk';
my $good_url = 'http://farm1.static.flickr.com/85/233472093_1f1d235e7b_d.jpg';

# This url returns '403' for HEAD requests - so code should fall back to 'GET'
my $get_only_url = 'http://x80.xanga.com/f32c900426733206272947/z160426333.jpg';

# check that the can_capture_url code works
ok !$image_rs->can_capture_url($bad_url), "can't capture '$bad_url'";
ok $image_rs->can_capture_url($good_url),     "can capture '$good_url'";
ok $image_rs->can_capture_url($get_only_url), "can capture '$get_only_url'";

$image_rs->search( { source_url => $good_url } )->delete;
my $image = $image_rs->create( { source_url => $good_url } );

ok $image, "Created a new image";

my @paths = ();

for (qw(original small medium large)) {
    my $path = $image->full_path_to_image($_);
    ok -e $path, "Found $_: $path";
    push @paths, $path;
}

ok $image->delete, "delete image";

ok( !-e $_, "file now deleted: $_" ) for @paths;
