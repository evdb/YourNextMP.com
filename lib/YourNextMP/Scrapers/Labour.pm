package YourNextMP::Scrapers::Labour;
use base 'YourNextMP::Scrapers::ScraperBase';

use strict;
use warnings;
use Web::Scraper;
use App::Cache;

sub can_do_candidate_url {
    my $class = shift;
    my $url   = shift;

    return $url =~ m{ \A http://www.labour.org.uk/ }xms;
}

sub can_do_candidate_list {
    my $class = shift;
    my $code  = shift;

    return $code eq 'labour';
}

sub extract_candidate_data {
    my $class     = shift;
    my $candidate = shift;
    my $data      = {};
    my $html      = $class->cache->get_url( $candidate->scrape_source );

    my %blocks =
      $html =~ m{ BLOCK: \s+ (\w+) \s+ --> (.*?) <!-- \s+ ENDBLOCK: }xmsg;

    for ( values %blocks ) {
        s{<strong>.*?</strong>}{}g;
        s{<h1>.*?</h1>}{}g;
        s{<.*?>}{}g;
        s{\s+}{ }g;
        s{^\s+}{};
        s{\s+$}{};
    }

    $data->{email}   = $blocks{EmailAddress};
    $data->{phone}   = $blocks{Telephone};
    $data->{address} = $blocks{PostalAddress};

    $data->{links}{"Profile"}   = $candidate->scrape_source;
    $data->{links}{"Home Page"} = 'http://' . $blocks{WebsiteAddress}
      if $blocks{WebsiteAddress};

    # grab the photo
    my ($image_path) = $html =~ m{src="(images/people/\d+/\w+_200.jpg)"};
    if ($image_path) {
        $image_path =~ s{_200}{_250}; # get a bigger image
        $data->{photo_url} = "http://www.labour.org.uk/" . $image_path;
    }

    return $data;
}

sub extract_candidate_list {
    my $class = shift;

    # The labour ppc list is not complete - it does not contain current MPs. To
    # tackle this we make the _bad_ assumption that unless there is a PPC listed
    # for the seat then the current MP will stand again. Hence scrape the PPCs
    # first and add all to list. Then scrape MPs and add any for seats not
    # already seen on PPC list.

    my $ppc_list = "http://www.labour.org.uk/ppc/constituencies/";
    my $mp_list  = "http://www.labour.org.uk/mp/constituencies/";

    my $ppcs = $class->_fetch_candidates($ppc_list);
    my $mps  = $class->_fetch_candidates($mp_list);

    # sort out the results
    my @candidates = ();
    my %seen_seats = ();

    # Grab from ppc list, then remaining seats from mp list
    push @candidates, map { $seen_seats{ $_->{seat} }++; $_ } @$ppcs;
    push @candidates, grep { !$seen_seats{ $_->{seat} } } @$mps;

    # Filter out bad seats
    my $seat_rs = YourNextMP::Schema::YourNextMPDB->resultset('Seat');
    @candidates = grep { $seat_rs->find( { name => $_->{seat} } ) } @candidates;

    return \@candidates;
}

sub _fetch_candidates {
    my $class = shift;
    my $url   = shift;
    my $html  = $class->cache->get_url($url);

    my $scraper = scraper {
        process 'ul.swc_List li', 'candidates[]' => scraper {
            process 'a',
              name => [ 'TEXT', sub { m{Labour (?:PPC|MP) (.*)}; $1 } ];
            process 'a', seat => [ 'TEXT', sub { m{(.*), Labour}; $1 } ];
            process 'a', scrape_source => '@href';
        };
    };

    my $candidates = $scraper    #
      ->scrape( $html, $url )    #
      ->{candidates};

    return $candidates;
}

1;
