#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Web::Scraper;
use URI;
use LWP::Simple;
use File::Slurp;
use Path::Class;
use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;
use YourNextMP::Schema::YourNextMPDB;

my $start_page =
'http://www.conservatives.com/People/Prospective_Parliamentary_Candidates.aspx?by=All';

my $candidate_list_scraper = scraper {
    process 'tbody tr', 'candidates[]' => scraper {
        process 'td a',    name          => 'TEXT';
        process 'td a',    scrape_source => '@href';
        process '//td[2]', seat          => 'TEXT';
    };
};

my $candidates                         #
  = $candidate_list_scraper            #
  ->scrape( URI->new($start_page) )    #
  ->{candidates};

my $con_rs = YourNextMP::Schema::YourNextMPDB->resultset('Seat');
my $can_rs = YourNextMP::Schema::YourNextMPDB->resultset('Candidate');

my $party_id =
  YourNextMP::Schema::YourNextMPDB->resultset('Party')
  ->find( { code => 'conservative' } )->id;

foreach my $can (@$candidates) {

    next unless $can->{seat};

    print "Looking at '$can->{name}'\n";

    my $seat = $con_rs->find( { code_from_name => $can->{seat} } )
      || warn("Can't find seat '$can->{seat}'") && next;
    delete $can->{seat};

    $can->{code}  = $can_rs->name_to_code( $can->{name} );
    $can->{name}  = $can_rs->clean_name( $can->{name} );
    $can->{party} = $party_id;

    # create the candidate
    my $candidate = $can_rs->update_or_create($can);
    $candidate->add_to_candidacies( { seat => $seat } )
      unless $candidate->candidacies( { seat_id => $seat->id } )->count;

}
