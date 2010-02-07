package YourNextMP::Scrapers::LiberalDemocrats;
use base 'YourNextMP::Scrapers::ScraperBase';

use strict;
use warnings;

use strict;
use warnings;
use Web::Scraper;
use App::Cache;
use Encode;

sub can_do_candidate_url {
    my $class = shift;
    my $url   = shift;

    return $url =~ m{ \A http://www.libdems.org.uk/ }xms;
}

sub can_do_candidate_list {
    my $class = shift;
    my $code  = shift;

    return $code eq 'liberal_democrats';
}

sub extract_candidate_data {
    my $class     = shift;
    my $candidate = shift;
    my $data      = {};
    my $html      = $class->cache->get_url( $candidate->scrape_source );

    my $scraper = scraper {
        process '#divIntroduction h2 a',       seat_name1 => 'text';
        process '#divIntroduction h2',         seat_name2 => 'html';
        process '#divIntroduction img',        photo_url  => '@src';
        process '#divBiography p',             'bio[]'    => 'text';
        process '#divBiography',               'bio2'     => 'text';
        process '#divIndividualContactInfo a', 'links[]'  => '@href';
        process '#divIndividualContactInfo ul.address li',
          'address[]' => 'TEXT';
        process '#divIndividualContactInfo', 'contacts' => 'text';
    };

    $data = $scraper->scrape( $html, $candidate->scrape_source );

    # Get the seat and clean it up
    my $seat_name1 = delete( $data->{seat_name1} );
    my $seat_name2 = delete( $data->{seat_name2} );
    $data->{seat} = $seat_name1 || $seat_name2 || '';
    for ( $data->{seat} ) {
        s{&#(\d+);}{ chr($1) }eg;
        s{^.* for ([\w\s&\-]*).*$}{$1};
    }

    # Extract the bio
    $data->{bio} ||= [ $data->{bio2} ];
    $data->{bio} = join "\n\n", @{ $data->{bio} || [] };
    delete $data->{bio2};
    eval { $data->{bio} = decode( 'latin1', $data->{bio} ) };
    $data->{bio} =~ s{^Biography\s*}{};

    # get the address
    $data->{address} = join ", ",
      map { s/\s*$//; $_ } @{ $data->{address} || [] };
    delete $data->{address} if length( $data->{address} ) > 190;

    # Extract the interesting bits from the contact details
    for ( delete $data->{contacts} ) {
        my $number_regex = '\s+ ([\s\d]+)';
        $data->{phone} = join ',', m{ Telephone: $number_regex }xmsg;
        $data->{fax}   = join ',', m{ Fax: $number_regex }xmsg;
    }

    # links
    my $links_found = delete $data->{links};
    my %links       = ();

    $links{"Profile"} = $candidate->scrape_source;

    foreach my $link (@$links_found) {
        if ( $link =~ m{\@} ) {
            $data->{email} = $link->to;
        }
        else {
            $links{'Home page'} = $link . '';
        }
    }
    $data->{links} = \%links;    #FIXME

    return $data;
}

sub extract_candidate_list {
    my $class = shift;

    my $start_page =
        'http://www.libdems.org.uk'
      . '/parliamentary_candidates.aspx'
      . '?show=Candidates&pgNo=';

    my $scraper = scraper {
        process 'div.divWhoWeAreItem', 'candidates[]' => scraper {
            process 'h2',   heading       => 'TEXT';
            process 'h2 a', scrape_source => '@href';
        };
    };

    my $candidates = [];
    foreach my $current_page ( 0 .. 200 ) {
        print "Fetching candidates from page $current_page\n";

        my $url  = $start_page . $current_page;
        my $html = $class->cache->get_url($url);

        my $new_candidates = $scraper    #
          ->scrape( $html, $url )        #
          ->{candidates};

        last if !$new_candidates;
        push @$candidates, @$new_candidates;
    }

    # work out what to split the heading on
    my $sep = qr{ \s+ \x{2013} \s+ }x;    # &ndash;

    foreach my $can (@$candidates) {
        my $heading = delete $can->{heading};
        my ( $name, $seat ) = split $sep, $heading, 2;

        $can->{name} = $name;

        if ( $seat && $seat =~ m{PPC for (.*)$} ) {
            $can->{seat} = $1;
        }

        $_ = decode( 'utf8', $_ ) for values %$can;

    }

    return $candidates;

}

1;

