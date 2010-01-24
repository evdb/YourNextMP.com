#!/usr/bin/env perl

use strict;
use warnings;

use File::Finder;
use Path::Class;
use Digest::MD5;
use Carp;

my @schema_files    #
  = File::Finder    #
  ->type('f')       #
  ->name('*.pm')    #
  ->in('lib/YourNextMP/Schema/');

foreach my $filename (@schema_files) {

    print "Looking at '$filename'...\n";

    open( my $read_fh, '<', $filename )
      or croak "Cannot open '$filename' for reading: $!";

    my $mark_re =
qr{^(# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:)([A-Za-z0-9/+]{22})\n};

    my $found  = 0;
    my $buffer = '';
    while (<$read_fh>) {

        # warn $_;

        if ( !$found && /$mark_re/ ) {
            $found = 1;

            my $md5sum_line = $_;
            $buffer .= $1;

            my $old_checksum = $2;
            my $new_checksum = Digest::MD5::md5_base64($buffer);

            $buffer .= "$new_checksum\n";

            if ( $old_checksum ne $new_checksum ) {
                print "  ...changing $old_checksum to $new_checksum\n";
            }
            else {
                print "  ...no change needed\n";
            }

        }
        else {
            $buffer .= $_;
        }
    }

    close $read_fh;

    if ($found) {
        open( my $write_fh, '>', $filename )
          or croak "Cannot open '$filename' for writing: $!";
        print $write_fh $buffer;
        close $write_fh;
    }
}
