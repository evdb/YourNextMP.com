#!/usr/bin/env perl

use strict;
use warnings;

use local::lib '/var/www/perl5';

use autodie;

use autodie qw(:all);
use Path::Class;
use File::Finder;

# check that we are root
die "Must run this script as root"    #
  if $< != 0;

# get to the right directory
my $root_dir = dir('/var/www');
chdir $root_dir;

# find the latest released production directory
my $current_production_dir = $root_dir->subdir('yournextmp_production');

# work out the name of the new production directory
chdir $root_dir;
my ($highest_dir_name) =
  sort { $b cmp $a }                        #
  grep { m{yournextmp_production_\d+$} }    #
  File::Finder                              #
  ->type('d')                               #
  ->name('yournextmp_production_*')         #
  ->depth(1)                                #
  ->in('.');

my ($dir_version_number) = $highest_dir_name =~ m{_(\d+)$};
$dir_version_number++;
my $new_production_dir =
  $root_dir->subdir("yournextmp_production_$dir_version_number");

my $control_script = '/etc/init.d/yournextmp_production.sh';

# stop the server
system $control_script, 'stop';
system "rm -v $current_production_dir";
system "ln -s -v $new_production_dir $current_production_dir";
system "chown -v www-data:www-data $current_production_dir";
system $control_script, 'start';

