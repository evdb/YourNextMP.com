#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Web::Scraper;
use URI;
use LWP::Simple;
use File::Slurp;
use Path::Class;
use Encode;
use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;
use YourNextMP::Schema::YourNextMPDB;

my $start_page =
'http://www.libdems.org.uk/parliamentary_candidates.aspx?show=Candidates&pgNo=';

my $candidate_list_scraper = scraper {
    process 'div.divWhoWeAreItem', 'candidates[]' => scraper {
        process 'h2',   note => 'TEXT';
        process 'h2 a', url  => '@href';
    };
};

my $candidates = [];
foreach my $current_page ( 0 .. 100 ) {
    print "Fetching candidates from page $current_page\n";

    my $url       = $start_page . $current_page;
    my $html_file = "/tmp/scrapers/lib_dem/list-$current_page.html";
    file($html_file)->dir->mkpath;

    mirror( $url, $html_file ) unless -e $html_file;
    my $html = read_file($html_file);

    my $new_candidates = $candidate_list_scraper    #
      ->scrape( $html, $url )                       #
      ->{candidates};

    last if !$new_candidates;
    push @$candidates, @$new_candidates;
}

my $con_rs         = YourNextMP::Schema::YourNextMPDB->resultset('Seat');
my $can_rs         = YourNextMP::Schema::YourNextMPDB->resultset('Candidate');
my $candidacies_rs = YourNextMP::Schema::YourNextMPDB->resultset('Candidacy');
my $files_rs       = YourNextMP::Schema::YourNextMPDB->resultset('File');

foreach my $can (@$candidates) {

    my $note = delete $can->{note};
    my ($name) = $note =~ m{^([\w\s]+)}g;
    $name =~ s{\s*$}{};
    $can->{name} = $name;

    print "Looking at '$name'\n";

    $can->{code}  = $can_rs->name_to_code( $can->{name} );
    $can->{party} = 'liberal_democrats';

    # $can->{seat}  = $seat->code;                             # FIXME

    my $html_file = "/tmp/scrapers/lib_dem/$can->{code}.html";
    next if -e $html_file;
    mirror( $can->{url}, $html_file ) unless -e $html_file;
    my $html = read_file($html_file);

    my $results = scraper {
        process '#divIntroduction h2 a',       seat_name1 => 'text';
        process '#divIntroduction h2',         seat_name2 => 'html';
        process '#divIntroduction img',        photo      => '@src';
        process '#divBiography p',             'bio[]'    => 'text';
        process '#divBiography',               'bio2'     => 'text';
        process '#divIndividualContactInfo a', 'links[]'  => '@href';
        process '#divIndividualContactInfo ul.address li',
          'address[]' => 'TEXT';
        process '#divIndividualContactInfo', 'contacts' => 'text';
    }
    ->scrape( $html, $can->{url} );
    $can->{$_} = $results->{$_} for keys %$results;

    # warn Dumper($can);

    my $seat_name1 = delete( $can->{seat_name1} );
    my $seat_name2 = delete( $can->{seat_name2} );
    my $seat_name =
         $seat_name1
      || $seat_name2
      || die "Could not find a seat_name for $name";
    $seat_name =~ s{&#(\d+);}{ chr($1) }eg;
    $seat_name =~ s{^.* for ([\w\s&\-]*).*$}{$1};
    my $seat = $con_rs->find( { code_from_name => $seat_name } )
      || warn("Can't find seat '$seat_name'") && next;

    $can->{bio} ||= [ $can->{bio2} ];
    $can->{bio} = join "\n\n", @{ $can->{bio} || [] };
    delete $can->{bio2};
    eval { $can->{bio} = decode( 'latin1', $can->{bio} ) };
    $can->{bio} =~ s{^Biography\s*}{};
    $can->{address} = join ", ",
      map { s/\s*$//; $_ } @{ $can->{address} || [] };

    # Extract the interesting bits from the contact details
    for ( delete $can->{contacts} ) {
        my $number_regex = '\s+ ([\s\d]+)';
        $can->{phone} = join ',', m{ Telephone: $number_regex }xmsg;
        $can->{fax}   = join ',', m{ Fax: $number_regex }xmsg;
    }

    # links
    my $links_found = delete $can->{links};
    my %links       = ();

    $links{"Profile"} = delete( $can->{url} ) . '';

    foreach my $link (@$links_found) {
        if ( $link =~ m{\@} ) {
            $can->{email} = $link->to;
        }
        else {
            $links{'Home page'} = $link . '';
        }
    }

    # $can->{links} = \%links;    #FIXME

    # grab the photo
    if ( my $photo_url = delete $can->{photo} ) {
        my $photo = $files_rs->create_from_url($photo_url);
        $can->{photo} = $photo->md5;
    }

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
