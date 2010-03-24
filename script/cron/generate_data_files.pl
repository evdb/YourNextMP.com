#!/usr/bin/env perl

use strict;
use warnings;

use YourNextMP;
use JSON;
use DateTime;
use IO::Compress::Gzip qw(gzip $GzipError);

generate_main_json();

sub generate_main_json {

    # Fetch all candidates, parties, constituencies and candidacies
    my %fetch_spec = (
        Candidate => {
            fields => [
                'id',      'code',    'status',  'party_id',
                'created', 'updated', 'name',    'email',
                'phone',   'fax',     'address', 'image_id',
            ],
            where => {},
        },
        Party => {
            fields =>
              [ 'id', 'code', 'created', 'updated', 'name', 'image_id', ],
            where => {},
        },
        Seat => {
            fields => [ 'id', 'code', 'created', 'updated', 'name', ],
            where  => {},
        },
        Candidacy => {
            fields =>
              [ 'candidate_id', 'seat_id', 'created', 'updated', 'id', ],
            where => {},
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
    my $json = JSON->new->pretty->utf8->encode( \%data );

    # uplaod it to the server
    upload_to_s3_and_save_to_db(
        {
            type    => 'json_main',
            suffix  => 'json',
            content => $json,
            name    => 'JSON of candidates, candidacies, parties and seats',
        }
    );
}

sub upload_to_s3_and_save_to_db {
    my $args = shift;
    my $now  = DateTime->now;

    # s3 key
    my $file_name = join( '-', $args->{type}, $now->ymd(''), $now->hms('') )   #
      . ".$args->{suffix}.gz";
    my $s3_key = join '/', "data_files", $args->{type}, $now->year, $now->month,
      $now->day, $file_name;

    # get the content and compress it
    my $uncomressed = $args->{content};
    my $compressed  = '';
    gzip \$uncomressed => \$compressed
      or die "gzip failed: $GzipError\n";

    # upload to s3
    my $bucket = YourNextMP->s3_bucket;
    my $object = $bucket->object(
        key          => $s3_key,
        content_type => 'application/gzip',
        acl_short    => 'private',
    );

    # $object->put($compressed);

    # create an entry in the database
    YourNextMP->db('DataFile')->create(
        {
            name    => $args->{name},
            type    => $args->{type},
            s3_key  => $s3_key,
            created => $now,
        }
    );
}
