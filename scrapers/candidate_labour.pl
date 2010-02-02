#!/usr/bin/env perl

use strict;
use warnings;

use Web::Scraper;
use URI;
use LWP::Simple;
use File::Slurp;
use Path::Class;
use Encode;
use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;
use YourNextMP::Schema::YourNextMPDB;

my @start_pages = (
    "http://www.labour.org.uk/ppc/constituencies/",
    "http://www.labour.org.uk/mp/constituencies/"
);

foreach my $start_page (@start_pages) {

    my $candidate_list_scraper = scraper {
        process 'ul.swc_List li', 'candidates[]' => scraper {
            process 'a',
              name => [ 'TEXT', sub { m{Labour (?:PPC|MP) (.*)}; $1 } ];
            process 'a', seat_name => [ 'TEXT',  sub { m{(.*), Labour}; $1 } ];
            process 'a', url       => '@href';
            process 'a', labour_id => [ '@href', sub { m{/(\d+)};       $1 } ];
        };
    };

    my $candidates = $candidate_list_scraper    #
      ->scrape( URI->new($start_page) )         #
      ->{candidates};

    # die Dumper($candidates);

    my $con_rs     = YourNextMP::Schema::YourNextMPDB->resultset('Seat');
    my $can_rs     = YourNextMP::Schema::YourNextMPDB->resultset('Candidate');
    my $parties_rs = YourNextMP::Schema::YourNextMPDB->resultset('Party');
    my $candidacies_rs =
      YourNextMP::Schema::YourNextMPDB->resultset('Candidacy');
    my $files_rs = YourNextMP::Schema::YourNextMPDB->resultset('File');

    foreach my $can (@$candidates) {

        print "Looking at '$can->{name}'\n";

        $can->{code}  = $can_rs->name_to_code( $can->{name} );
        $can->{party} = 'labour';

        my $labour_id = delete $can->{labour_id};

        my $seat_name = delete $can->{seat_name};
        my $seat = $con_rs->find( { code_from_name => $seat_name } )
          || warn("Can't find seat '$seat_name'") && next;

        my %links = ();
        $links{"Profile"} = delete( $can->{url} ) . '';

        # create the candidate
        my $candidate = $can_rs->update_or_create($can);

        $candidate->add_to_candidacies( { seat => $seat } )
          unless $parties_rs->find( { code => 'labour' } )
          ->candidates( { seat => $seat->code }, { join => 'candidacies' } )
          ->count
          || $candidate->candidacies( { seat => $seat->code } )->count;

        # grab the photo
        if ( !$candidate->photo ) {
            my $photo_url =
              "http://www.labour.org.uk/images/people/$labour_id/image_200.jpg";
            print "\tgetting photo from $photo_url\n";
            my $photo = $files_rs->create_from_url($photo_url);
            $candidate->update( { photo => $photo->md5 } ) if $photo;
        }

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
}
