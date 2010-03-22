#!/usr/bin/env perl

use strict;
use warnings;

use autodie qw(:all);
use Path::Class;
use File::Finder;

# get to the right directory
my $root_dir  = dir('/var/www');
my $stage_dir = $root_dir->subdir('yournextmp_stage');
chdir $root_dir;

# find the latest released production directory
my $current_production_dir = $root_dir->subdir('yournextmp_production');

# work out the name of the new production directory
my $tmp_production_dir = $root_dir->subdir("yournextmp_production_new");
system 'rm', '-rf', $tmp_production_dir if -e $tmp_production_dir;

# go into stage and prep it
chdir $stage_dir;
system 'perl Makefile.PL';    # check for missing deps
system 'make realclean';

# copy stage to the new production directory
mkdir $tmp_production_dir;
chdir $tmp_production_dir;
system "cp -r $stage_dir/* .";

# remove files that should not have been copied
system 'rm', '-rf', '.git', '.gitignore', 'log';

# copy needed things out of the currenty live directory
system 'mv', 'yournextmp_local.pl', 'yournextmp_local_stage.pl';
system "cp -v $current_production_dir/yournextmp_local.pl .";

# check for changes that may cause trouble
my $diff =
`diff -u yournextmp_local_stage.pl $current_production_dir/yournextmp_local_stage.pl`;
if ($diff) {
    die ''                                                                   #
      . "##########################################\n"                       #
      . "Update the current yournextmp_local_stage.pl file to continue\n"    #
      . "##########################################\n"                       #
      . "\n\n"                                                               #
      . $diff;
}

# work out the name of the new production directory
chdir $root_dir;
my ($highest_dir_name) =
  sort { $b cmp $a }                                                         #
  grep { m{yournextmp_production_\d+$} }                                     #
  File::Finder                                                               #
  ->type('d')                                                                #
  ->name('yournextmp_production_*')                                          #
  ->depth(1)                                                                 #
  ->in('.');

my ($dir_version_number) = $highest_dir_name =~ m{_(\d+)$};
$dir_version_number++;
my $new_production_dir =
  $root_dir->subdir("yournextmp_production_$dir_version_number");

system 'mv', '-v', $tmp_production_dir, $new_production_dir;

# create the number that will be used to mark the static content
$new_production_dir                                                          #
  ->file('deployment_number.txt')                                            #
  ->openw()                                                                  #
  ->print($dir_version_number);
