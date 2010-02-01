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
        process 'td a',    name => 'TEXT';
        process 'td a',    url  => '@href';
        process '//td[2]', seat => 'TEXT';
    };
};

my $candidates                         #
  = $candidate_list_scraper            #
  ->scrape( URI->new($start_page) )    #
  ->{candidates};

my $con_rs         = YourNextMP::Schema::YourNextMPDB->resultset('Seat');
my $can_rs         = YourNextMP::Schema::YourNextMPDB->resultset('Candidate');
my $candidacies_rs = YourNextMP::Schema::YourNextMPDB->resultset('Candidacy');
my $files_rs       = YourNextMP::Schema::YourNextMPDB->resultset('File');

foreach my $can (@$candidates) {

    next unless $can->{seat};

    print "Looking at '$can->{name}'\n";

    my $seat = $con_rs->find( { code_from_name => $can->{seat} } )
      || warn "Can't find seat '$can->{seat}'" && next;
    delete $can->{seat};

    $can->{code}  = $can_rs->name_to_code( $can->{name} );
    $can->{party} = 'conservative';

    my $html_file = "/tmp/scrapers/conservatives/$can->{code}.html";
    file($html_file)->dir->mkpath;
    next if -e $html_file;
    mirror( $can->{url}, $html_file ) unless -e $html_file;
    my $html = read_file($html_file);

    my $results = scraper {

        # process 'div.main-txt',     html      => 'HTML';
        process 'div.main-txt p', contacts => 'html';

        process 'div.main-txt img', photo     => '@src';
        process 'div.main-txt a',   'links[]' => '@href';
        process 'div.main-txt',     'bio'     => 'HTML';
    }
    ->scrape( $html, $can->{url} );
    $can->{$_} = $results->{$_} for keys %$results;

    # Extract the interesting bits from the contact details
    for ( delete $can->{contacts} ) {
        my $number_regex = '\s+ <span> ([\s\d]+)</span>';
        $can->{phone} = join ',', m{ Tel: $number_regex }xmsg;
        $can->{fax}   = join ',', m{ Fax: $number_regex }xmsg;

        ( $can->{address} ) = m{ \s* ([^/]*?) \s* (?: <br | Email: ) }xmsg;
    }

    # bio - nasty cleanup of html
    for ( $can->{bio} ) {

        # warn "$_\n\n";
        s{^.*<div class="personBody">}{};
        s{.*\(opens in a new window\)}{};
        s{<br\s*/*>}{\n}g;
        s{</?(?:p|h\d).*?>}{\n\n}g;
        s{<.*?>}{}g;
        s{&#(\d+);}{ chr($1) }eg;
        s{\s*\n+\s*}{\n\n}g;
        s{\A\s*(.*?)\s*\z}{$1}xms;

        $_ .= "\n\nsource: $can->{url}";
    }

    # links
    my $links_found = delete $can->{links};
    my %links       = ();

    $links{"Profile"} = delete( $can->{url} ) . '';

    foreach my $link (@$links_found) {
        if ( $link =~ m{\@} ) {
            $can->{email} = $link->to;
        }
        elsif ( $link =~ m{javascript:mpExpensesPopup\('(\w+)'\);} ) {
            $links{'Expenses claims'} =
              "http://www.conservatives.com/expenses/expenses.aspx?name=$1";
        }
        else {
            $links{'Home page'} = $link . '';
        }

    }

    # grab the photo
    if ( my $photo_url = delete $can->{photo} ) {
        my $photo = $files_rs->create_from_url($photo_url);
        $can->{photo} = $photo->md5;
    }

    # warn Dumper($can);

    # create the candidate
    my $candidate = $can_rs->update_or_create($can);
    $candidate->add_to_candidacies( { seat => $seat } )
      unless $candidate->candidacies( { seat => $seat->code } )->count;

    # create the links for this candidate
    foreach my $title ( keys %links ) {
        $candidate->add_to_links(
            {
                title => $title,
                url   => $links{$title},
            }
        ) unless $candidate->links( { url => $links{$title}, } )->first;
    }

}

warn scalar @$candidates;
