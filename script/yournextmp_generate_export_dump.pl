#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;
use JSON;

# Fetch all candidates, parties, constituencies and candidacies
my %fetch_spec = (
    Candidate => {
        fields => [
            'id',      'code',    'party_id', 'created',
            'updated', 'name',    'email',    'phone',
            'fax',     'address', 'image_id',
        ],
        where => {},
    },
    Party => {
        fields => [ 'id', 'code', 'created', 'updated', 'name', 'image_id', ],
        where  => {},
    },
    Seat => {
        fields => [ 'id', 'code', 'created', 'updated', 'name', ],
        where  => {},
    },
    Candidacy => {
        fields => [ 'candidate_id', 'seat_id', 'created', 'updated', 'id', ],
        where  => {},
    },
);

# Extract the data from the database
my %data = ();
foreach my $source ( sort keys %fetch_spec ) {
    my $spec = $fetch_spec{$source};
    my $rs   = YourNextMP->db($source);

    my $results = $rs->search(    #
        $spec->{where},           #
        undef                     # { rows => 1 }
    );

    while ( my $row = $results->next ) {

        my $id = $row->id;
        my %add_to_data = map { $_ => $row->$_ } @{ $spec->{fields} };
        $_ .= '' for grep { defined } values %add_to_data;
        $data{$source}{$id} = \%add_to_data;
    }
}

# Encode to JSON and print out
print JSON->new->pretty->utf8->encode( \%data );
