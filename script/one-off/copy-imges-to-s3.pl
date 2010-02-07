#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;
use File::Finder;

my $dir = $ARGV[0];
die "Usage: $0 path_to_images/\n" unless $dir && -d $dir;

my @files = sort File::Finder->type('f')->depth->in($dir);

my $bucket = YourNextMP->s3bucket;

foreach my $file (@files) {
    my ($key) = $file =~ m{ / ( images / .* ) \z }xms;
    printf "copying %-60s --> %s\n", $file, $key;

    my $content_type =
        $key =~ m{\.png$}   ? 'image/png'
      : $key =~ m{\.jpe?g$} ? 'image/jpeg'
      : $key =~ m{\.gif$}   ? 'image/gif'
      :                       die "Can't determine mime-type for $key";

    my $object = $bucket->object(
        key          => $key,
        acl_short    => 'public-read',
        content_type => $content_type,
    );
    $object->put_filename($file);

}
