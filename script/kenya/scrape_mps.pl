#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;
use Web::Scraper;
use App::Cache;
use Text::Trim;
use Encode;

my $mps_url    #
  = 'http://www.parliament.go.ke/index.php'
  . '?option=com_content&view=article&id=88&Itemid=87';
my $mps_html = decode_utf8( App::Cache->new->get_url($mps_url) );

my $scraper = scraper {
    process 'tbody tr', 'mps[]' => scraper {
        ### process 'tr',                content      => 'HTML';
        process 'td:nth-child(1)',   name         => 'TEXT';
        process 'td:nth-child(2)',   constituency => 'TEXT';
        process 'td:nth-child(3)',   party        => 'TEXT';
        process 'td:nth-child(4) a', profile_link => '@href';
    };
};

my @mps = @{ $scraper->scrape( \$mps_html, $mps_url )->{mps} };

# first entries are just bumpf and headings
shift @mps;
shift @mps;

foreach my $mp (@mps) {

    for ( values %$mp ) {
        trim $_ for values %$mp;
    }

    print encode_utf8("Looking at $mp->{name} of $mp->{constituency}\n");

    my $seat =
      YourNextMP->model('Seat')
      ->find_or_create( { name => $mp->{constituency} } );

    my $party =
      YourNextMP->model('Party')->find_or_create( { name => $mp->{party} } );

    my $candidate = YourNextMP->model('Candidate')->find_or_create(
        {
            party_id => $party->id,
            name     => $mp->{name},
        }
    );

    my $candidacy = YourNextMP->model('Candidacy')->find_or_create(
        {
            candidate_id => $candidate->id,
            seat_id      => $seat->id,
        }
    );

    if ( my $url = $mp->{profile_link} ) {
        my $link = YourNextMP->model('Link')->find_or_create(
            {
                url       => "$url",
                title     => "Parliament Profile Page",
                link_type => 'info',
            }
        );
        $candidate->find_or_create_related(
            'link_relations',
            {
                foreign_table => 'candidates',
                link_id       => $link->id,
            }
        );

    }

}
