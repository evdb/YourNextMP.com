#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use Search::Sitemap;
use IO::Interactive qw( interactive );
use File::Temp;
use File::Slurp;


my $URL_BASE = 'http://' . YourNextMP->config->{base_host};

my $map = Search::Sitemap->new();
$map->pretty('nice');

foreach my $rs_name (qw(Candidate Seat Party)) {

    print {interactive} "Adding $rs_name to sitemap\n";
    my $rs = YourNextMP->db($rs_name)->search();

    while ( my $row = $rs->next ) {

        $map->add(
            Search::Sitemap::URL->new(
                loc        => $URL_BASE . $row->path,
                lastmod    => $row->updated->ymd('-'),
                changefreq => 'daily',
                priority   => 1.0,
            )
        );

    }
}

# create a temporary file and write to that
my $tmp_file = File::Temp->new( UNLINK => 0, SUFFIX => '.xml' );

print {interactive} "Writing file to $tmp_file\n";
$map->write("$tmp_file");
$tmp_file->flush;
$tmp_file->close;

# upload the sitemap to S3
print {interactive} "Uploading file to S3\n";
my $bucket = YourNextMP->s3_bucket;
my $object = $bucket->object(
    key          => 'sitemap.xml',
    content_type => 'application/xml',
    acl_short    => 'public-read',
);

$object->put_filename("$tmp_file");

print {interactive} "Deleting $tmp_file\n";
unlink $tmp_file;

print {interactive} "ALL DONE!\n";
