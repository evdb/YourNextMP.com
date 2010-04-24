#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use XML::Simple;
use YourNextMP;

use YourNextMP::Util::Cache;

my $cache = YourNextMP::Util::Cache->cache;
my $xml   = $cache->get_url('http://www.hustings.com/candidates/feed.rss');

my $data  = XMLin($xml)            || {};
my $items = $data->{channel}{item} || [];

my $links_rs      = YourNextMP->db('Link');
my $seats_rs      = YourNextMP->db('Seat');
my $candidates_rs = YourNextMP->db('Candidate');

foreach my $item (@$items) {

    # create the link and skip on if it already is attached to a candidate
    my $link = $links_rs->find_or_create(
        { url => $item->{link}, title => 'Hustings.com Profile' },
        { key => 'links_url_key' } #
    );
    next if $link->candidates->count;

    # sanity check the constituency
    my ($seat_name) = $item->{description} =~ m{ : \s+ (.*) \z }xms;
    my $seat = $seats_rs->search( { name => $seat_name } )->first
      || $seats_rs->fuzzy_search( { name => $seat_name } )->first;
    if ( !$seat ) {
        warn "Can't find seat '$seat_name' for link $item->{link}\n";
        next;
    }

    # Find the candidate.
    my $candidate =
         $seat->candidates->search( { name => $item->{title} } )->first
      || $seat->candidates->fuzzy_search( { name => $item->{title} } )->first;
    if ( !$candidate ) {
        warn
"Can't find candidate '$item->{title}' in '$seat_name' for link $item->{link}\n";
        next;
    }

    # create the link
    $link->add_to_link_relations(
        {
            foreign_table => 'candidates',
            foreign_id    => $candidate->id
        }
    );

}
