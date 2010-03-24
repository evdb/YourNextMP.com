#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use IO::Interactive qw( interactive );
use File::Temp;
use autodie ':all';
use DateTime;

# capture the current time
my $now = DateTime->now();

# which database should we back up?
my $dsn = YourNextMP->config->{'Model::DB'}{connect_info}{dsn}
  || die "could not get dsn";
my ($dbname) = $dsn =~ m{ dbname = (\w+) }xms;   #'dbi:Pg:dbname=yournextmp_dev'

# get a temporary file and dump the database to it
my $tmp_file = File::Temp->new( UNLINK => 0, SUFFIX => '.dump' );
print {interactive} "Dumping database $dbname to $tmp_file\n";
system 'pg_dump',                                #
  '-Fc',                                         # custom compressed file format
  '-f' => "$tmp_file",                           # save to tmp file
  $dbname;                                       # database to dump

# work out what the S3 file should be
my $s3_key = join '/', 'backups/db', $dbname,
  $now->strftime('%Y/%m/%d/%Y%m%d-%H%M%S.dump');

# upload file to S3
print {interactive} "Uploading file to S3: $s3_key\n";
my $bucket = YourNextMP->s3_bucket;
$bucket->object(
    key       => $s3_key,
    acl_short => 'private',
)->put_filename("$tmp_file");

print {interactive} "Deleting $tmp_file\n";
unlink $tmp_file;

print {interactive} "ALL DONE!\n";
