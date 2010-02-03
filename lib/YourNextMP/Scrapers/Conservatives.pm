package YourNextMP::Scrapers::Conservatives;
use base 'YourNextMP::Scrapers::ScraperBase';

use strict;
use warnings;
use Web::Scraper;
use App::Cache;

sub can_do_candidate_url {
    my $class = shift;
    my $url   = shift;

    return $url =~ m{ \A http://www.conservatives.com/ }xms;
}

sub can_do_candidate_list {
    my $class = shift;
    my $code  = shift;

    return $code eq 'conservative';
}

sub extract_candidate_data {
    my $class     = shift;
    my $candidate = shift;

    my $html = $class->cache->get_url( $candidate->scrape_source );
    my $data = scraper {

        # process 'div.main-txt',     html      => 'HTML';
        process 'div.main-txt p', contacts => 'html';

        process 'div.main-txt img', photo_url => '@src';
        process 'div.main-txt a',   'links[]' => '@href';
        process 'div.main-txt',     'bio'     => 'HTML';
    }
    ->scrape( $html, $candidate->scrape_source );

    # Extract the interesting bits from the contact details
    for ( delete $data->{contacts} ) {
        my $number_regex = '\s+ <span> ([\s\d]+)</span>';
        $data->{phone} = join ',', m{ Tel: $number_regex }xmsg;
        $data->{fax}   = join ',', m{ Fax: $number_regex }xmsg;

        ( $data->{address} ) = m{ \s* ([^/]*?) \s* (?: <br | Email: ) }xmsg;
    }

    # bio - nasty cleanup of html
    for ( $data->{bio} ) {

        # warn "$_\n\n";
        s{^.*<div class="personBody">}{};
        s{.*\(opens in a new window\)}{};
        s{<br\s*/*>}{\n}g;
        s{</?(?:p|h\d).*?>}{\n\n}g;
        s{<.*?>}{}g;
        s{&#(\d+);}{ chr($1) }eg;
        s{\s*\n+\s*}{\n\n}g;
        s{\A\s*(.*?)\s*\z}{$1}xms;
    }

    # links
    my $links_found = delete $data->{links};
    my %links       = ();
    $data->{links} = \%links;

    $links{"Profile"} = $candidate->scrape_source;

    foreach my $link (@$links_found) {
        if ( $link =~ m{\@} ) {
            $data->{email} = $link->to;
        }
        elsif ( $link =~ m{javascript:mpExpensesPopup\('(\w+)'\);} ) {
            $links{'Expenses claims'} =
              "http://www.conservatives.com/expenses/expenses.aspx?name=$1";
        }
        else {
            $links{'Home page'} ||= $link . '';
        }

    }

    $data->{photo_url} .= '';

    return $data;
}

sub extract_candidate_list {
    my $class = shift;

    my $scraper = scraper {
        process 'tbody tr', 'candidates[]' => scraper {
            process 'td a',    name          => 'TEXT';
            process 'td a',    scrape_source => '@href';
            process '//td[2]', seat          => 'TEXT';
        };
    };

    my $start_page    #
      = 'http://www.conservatives.com'
      . '/People/Prospective_Parliamentary_Candidates.aspx?by=All';

    my $html = $class->cache->get_url($start_page);

    my $candidates    #
      = $scraper      #
      ->scrape( $html, $start_page )    #
      ->{candidates};

    my @to_return = grep { $_->{seat} } @$candidates;
    return \@to_return;

}

1;
