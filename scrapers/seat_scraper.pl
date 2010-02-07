#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use WWW::Mechanize;
use Web::Scraper;
use URI;
use Encode;
use YourNextMP::Schema::YourNextMPDB;
use Digest::MD5 'md5_hex';
use Path::Class;

my $wikipedia_url =
'http://en.wikipedia.org/wiki/Constituencies_in_the_next_United_Kingdom_general_election';

my $scraper = scraper {
    process 'tr', 'seats[]' => scraper {
        process 'a', name => 'TEXT';
        process 'a', url  => '@href';
    };
};

my $seats = $scraper                      #
  ->scrape( URI->new($wikipedia_url) )    #
  ->{seats};

my $con_rs = YourNextMP->model('Seat');

foreach my $con (@$seats) {

    # filter out some false matches
    next unless $con->{url} && $con->{url} =~ m{UK_Parliament_constituency};

    $con->{code} = $con_rs->name_to_code( $con->{name} );
    my $url = delete $con->{url};

    my $consituency = $con_rs->find_or_create($con);
    $consituency->add_to_links(
        {
            url   => $url,
            title => 'Wikipedia Article',
        }
    ) unless $consituency->links( { title => 'Wikipedia Article' } )->first;
}
