#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use WWW::Mechanize;
use Web::Scraper;
use URI;
use Encode;
use YourNextMP;
use IO::Interactive qw(interactive);

sub burp ( @ ) { printf {interactive} @_; }

my $commision_site = 'http://registers.electoralcommission.org.uk';
my $base_search_page =
  $commision_site . '/regulatory-issues/regpoliticalparties.cfm';

my $parties_rs = YourNextMP->model('Party');
my $images_rs  = YourNextMP->model('Image');

# create the edge cas parties
$parties_rs->find_or_create(
    {
        code => 'independent',
        name => 'Independent',
    }
);
$parties_rs->find_or_create(
    {
        code => 'speaker_seeking_reelection',
        name => 'Speaker seeking re-election',
    }
);

scrape_parties(1);
scrape_parties(0);

sub scrape_parties {
    my $frmGB = shift() ? 1 : 0;

    my $search_page = "$base_search_page?frmGB=$frmGB";

    # Get the list of party names.
    my $mech = WWW::Mechanize->new;
    $mech->get($search_page);
    $mech->submit_form( form_id => 'frmSearch' );
    my $results_html = decode( 'latin1', $mech->content );

    # die burp $results_html;

    # Extract the names and url of all the parties
    my $results = scraper {
        process '#content li', 'parties[]' => scraper {
            process 'a', name          => 'TEXT';
            process 'a', commision_url => '@href';
        };
    }
    ->scrape( $results_html, $commision_site );

    my $emblem_scraper = scraper {
        process '#content img', url => '@src';
    };

    # Extract the emblems and add them to the mix
    foreach my $party ( @{ $results->{parties} } ) {

        burp "Looking at $party->{name}\n";

        # create the code for this party
        $party->{name} = $parties_rs->clean_name( $party->{name} );
        $party->{code} = $parties_rs->name_to_code( $party->{name} );

        # extract the electoral_commision_id
        my $commision_url = delete $party->{commision_url};
        my ($id) = $commision_url =~ m{frmPartyID=(\d+)};
        $party->{electoral_commision_id} = $id;

        # must have this id
        if ( !$id ) {
            warn "Missing electoral_commision_id for $commision_url\n";
            next;
        }

        # scrape the emblem off the electoral commission site
        my $emblem_page_url =
          $search_page . "&frmPartyID=$id" . "&frmType=emblemdetail";
        my $emblem_url =
          ( $emblem_scraper->scrape( URI->new($emblem_page_url) )->{url} || '' )
          . '';

        # Fetch the emblem if it exists
        if ($emblem_url) {
            burp "\tFetching emblem for $party->{name}\n";
            my $image =
              $images_rs->find_or_create( { source_url => $emblem_url } );
            $party->{image_id} = $image->id;
        }

        my $p = $parties_rs->find_or_create(    #
            $party,
            { key => 'parties_electoral_commision_id_key' }
        );

        # check that the party name has not changed - if it has complain
        if ( $p->name ne $party->{name} ) {
            warn sprintf "Party name changed: %s -> %s\n", $p->name,
              $party->{name};
        }

        my $link_title = 'Electoral Commission Entry';
        $link_title .= ' (Northern Ireland)' if !$frmGB;

        my $link = YourNextMP->db('Link')->find_or_create(
            {
                link_type => 'info',
                url       => $commision_url,
                title     => $link_title,
            }
        );

        $p->find_or_create_related(
            'link_relations',
            {
                foreign_table => 'parties',
                link_id       => $link->id,
            }
        );
    }

}
