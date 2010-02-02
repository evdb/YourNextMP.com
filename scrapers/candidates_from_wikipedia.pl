#!/usr/bin/env perl

=pod

This script will go to every constituency page on wikipedia and extract the
currently listed candidates and ensure that we have an entry for them.

=cut

use strict;
use warnings;
use YourNextMP::Schema::YourNextMPDB;
use File::Slurp;
use LWP::UserAgent;
use XML::Simple;
use Path::Class;
use utf8;

use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;

sub run {
    my $mech = LWP::UserAgent->new( agent => 'FooBar' );

    my $work_dir = dir('tmp/candidates_from_wikipedia');
    $work_dir->mkpath;
    my $touch_file = $work_dir->file('last_checked_seat.txt');

    my $seats_rs                            #
      = YourNextMP::Schema::YourNextMPDB    #
      ->resultset('Seat')                   #
      ->search( {}, { order_by => ['code'] } );

    while ( my $seat = $seats_rs->next ) {

        # check that we are ready to roll
        my $last_seat = $touch_file->slurp if -e $touch_file;
        next if $last_seat && $last_seat ge $seat->code;

        # next unless $seat->code eq 'argyll_and_bute';

        printf "\n\n--------- %s -------------\n", $seat->name;

        # Get the wikipedia link
        my $link = $seat->links( { title => 'Wikipedia Article' } )->single
          || next;

        # get the url and transform to export url
        # http://en.wikipedia.org/wiki/Special:Export/FooBar
        my $url = $link->url;
        $url =~ s{/wiki/}{/wiki/Special:Export/};

        # Fetch the XML
        my $xml_file = $work_dir->file( $seat->code . '.txt' );
        unless ( -e $xml_file ) {

            # die;
            $xml_file->openw->print( $mech->get($url)->content );
            sleep 2;
        }

        # Extract the actual text from the xml
        my $document = XMLin( $xml_file->openr );
        my $text     = $$document{page}{revision}{text}{content};

        my @election_boxes = $text =~ m{
        (
        \{\{Election\ box\ begin
        .*?
        {{Election\ box\ end}}
        )
    }xmsg;

        my @extracted =
          grep { $_->{title} =~ m{2010} }    #
                # map { printf "\t\ttitle: %s\n", $_->{title}; $_; }
          grep { $_->{title} }    #
          extract_elections(@election_boxes);

        # print Dumper( $extracted[0] );

        foreach my $row ( @{ $extracted[0]->{rows} } ) {

            my $entry = create_entry($row) || next;

            $entry->{seat} = $seat;

            # print Dumper($entry);

            put_entry_in_db($entry);

        }

        $touch_file->openw->print( $seat->code );
    }

}

sub extract_elections {
    return map { extract_election($_) } @_;
}

sub extract_election {
    my $text = shift;
    my $data = {};

    my @boxes = $text =~ m[ {{ (.*?) }} ]xmsg;
    my @rows = ();

    for (@boxes) {

        # warn "\n\n------------------\n\n";
        # warn $_;

        my $row = {};
        ( $row->{_type} ) = m{^([^|]*)};

        for (m{ | \s* ( \w+ \s* = .*? ) (?:\n|\z) }xmsg) {
            next unless $_;
            my ( $key, $val ) = split /\s*=\s*/, $_, 2;
            $row->{$key} = $val;
        }

        # warn Dumper( $row);
        # die;

        # We dont want some rows
        next unless $row->{candidate} || $row->{title};

        $row->{candidate} =~ s{<ref>.*?</ref>}{}i if $row->{candidate};

        for ( values %$row ) {
            next unless $_;
            s{\s+}{ }g;
            s{^\s*}{};
            s{\s*$}{};
        }

        push @rows, $row;

    }

    return unless @rows;

    $data->{title} = shift(@rows)->{title};
    $data->{rows}  = \@rows;

    # warn Dumper(  $data );
    return $data;
}

sub create_entry {
    my $row = shift;

    my $candidate = $row->{candidate};
    my $party     = $row->{party};

    my $entry = {};
    $entry->{party_code} = party_name_to_code($party) || return;

    if ( $candidate =~ m{ \[\[ (.*) \]\] }xms ) {

        my ( $title, $name ) = split /\|/, $1, 2;

        $entry->{candidate_wikipedia_title} = $title;
        $entry->{candidate_name} = $name || $title;
    }
    elsif ( $candidate =~ m{\d} ) {
        return;
    }
    else {
        $candidate =~ s/ \s* (?: <ref | {{ | \[ | \| | \( ) .* //xms;
        $entry->{candidate_name} = $candidate;
    }

    return
      if $entry->{candidate_name} =~ m{TBC}
          || $entry->{candidate_name} =~ m{T\.B\.C\.}
          || $entry->{candidate_name} =~ m{TBC};

    return $entry;
}

my %PARTY_NAME_TO_CODE = (
    'British National Party'                   => 'british_national',
    'Scottish Conservative Party'              => 'conservative',
    'Conservative Party (UK)'                  => 'conservative',
    'Scottish Conservative and Unionist Party' => 'conservative',
    'Plaid Cymru'                              => 'plaid_cymru_party_of_wales',
    'Labour Party (UK)'                        => 'labour',
    'Labour Co-operative'                      => 'labour',
    'Welsh Labour Party'                       => 'labour',
    'Scottish Labour Party'                    => 'labour',
    'Welsh Liberal Democrats'                  => 'liberal_democrats',
    'Liberal Democrats (UK)'                   => 'liberal_democrats',
    'Liberal Democrats'                        => 'liberal_democrats',
    'Scottish Liberal Democrats'               => 'liberal_democrats',
    'Scottish National Party'                  => 'scottish_national',
    'Official Monster Raving Loony Party' => 'official_monster_raving_loony',
    'Green Party of England and Wales'    => 'green',
    'Green Party (UK)'                    => 'green',
    'Green Party'                         => 'green',
    'Green Party of Northern Ireland'     => 'green',
    'Scottish Green Party'                => 'scottish_green',
    'United Kingdom Independence Party'   => 'united_kingdom_independence',
    'English Democrats Party'             => 'english_democrats',
    'English Democrats'                   => 'english_democrats',
    'Social Democratic and Labour Party' => 'sdlp_social_democratic_and_labour',
    'Sinn Féin'                         => 'sinn_fein',
    'Respect - The Unity Coalition'      => 'respect_the_unity_coalition',
    'RESPECT The Unity Coalition'        => 'respect_the_unity_coalition',
    'Independent (politician)'           => 'independent',
    'Independent'                        => 'independent',
    'Communist Party of Britain'         => 'communist_party_of_britain',
    'Mebyon Kernow'              => 'mebyon_kernow_the_party_for_cornwall',
    'Unity Party'                => 'the_unity',
    'Libertarian Party (UK)'     => 'libertarian',
    'Democratic Unionist Party'  => 'democratic_unionist_party_d_u_p',
    'Scottish Socialist Party'   => 'scottish_socialist',
    'Best of a Bad Bunch'        => 'best_of_a_bad_bunch',
    'Christian Peoples Alliance' => 'christian_peoples_alliance',
    'Jury Team'                  => 'jury_team',
    'Liberal Party (UK, 1989)'   => 'liberal',
    'Scottish Senior Citizens Unity Party' => 'scottish_senior_citizens_unity',
    'Veritas (political party)'            => 'veritas',
    '[[The Youth Party]]'                  => 'youth',

    'Independent Kidderminster Hospital and Health Concern' =>
      'independent_kidderminster_hospital_and_health_concern',

    'Speaker of the British House of Commons' => 'independent',

    'Alliance Party of Northern Ireland' =>
      'alliance_alliance_party_of_northern_ireland',
    "Alliance for Workers' Liberty" => 'alliance_for_workers_liberty',
    'Trade Unionist and Socialist Coalition' =>
      'trade_unionist_and_socialist_coalition',

    # Not on electoral commission register
    'Cut Tax on Diesel and Petrol'        => '',
    'People\'s National Democratic Party' => '',
);

sub party_name_to_code {
    my $code = $PARTY_NAME_TO_CODE{ $_[0] };
    warn "Can't find code for party '$_[0]'" unless defined $code;
    return $code;
}

sub put_entry_in_db {
    my $entry = shift;

    printf "\t%s\n", $entry->{candidate_name};

    my $party                               #
      = YourNextMP::Schema::YourNextMPDB    #
      ->resultset('Party')                  #
      ->find( { code => $entry->{party_code} } )
      || die "no party matches '$entry->{party_code}'";

    my $candidate_rs = YourNextMP::Schema::YourNextMPDB    #
      ->resultset('Candidate');

    my $candidate = $candidate_rs                          #
      ->find_or_create(
        {
            code  => $candidate_rs->name_to_code( $entry->{candidate_name} ),  #
            name  => $entry->{candidate_name},
            party => $party,
        }
      );

    # assign the candidate to a seat
    $candidate->find_or_create_related(
        candidacies => {
            seat => $entry->{seat}                                             #
        }
    );

    # If there is a wikipedia page add that too
    if ( my $title = $entry->{candidate_wikipedia_title} ) {
        my $url = "http://en.wikipedia.org/wiki/$title";
        $candidate->find_or_create_related(
            links => {
                url   => $url,                                                 #
                title => 'Wikipedia Entry'
            }
        );
    }
}

run();
