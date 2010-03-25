#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use JSON;
use DateTime;
use IO::Compress::Gzip qw(gzip $GzipError);
use Text::CSV::Slurp;
use Encode;

generate_main_json();
generate_csv_files();

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

sub generate_csv_files {

    # create an array of hashes for all the candidates
    my $candidates_rs      #
      = YourNextMP         #
      ->db('Candidate')    #
      ->standing           #
      ->search( undef, { prefetch => 'party', order_by => 'me.code' } );
    my @candidates = ();

    while ( my $row = $candidates_rs->next ) {
        my %data = (
            'ID'            => $row->id,
            'Name'          => $row->name,
            'Email'         => $row->email,
            'Phone'         => $row->phone,
            'Address'       => $row->address,
            'Party Name'    => $row->party->name,
            'Seat Name(s)'  => join( ', ', $row->seat_names ),
            'Date of Birth' => $row->dob,
            'Age'           => $row->age,
            'School'        => $row->school,
            'University'    => $row->university,
            'Gender'        => $row->gender,
        );

        # tidy ups
        for ( grep { $_ } values %data ) {
            s{\s*\n\s*}{, }g;    # newlines to spaces
            s{\s+}{ }g;          # normalise spaces
            $_ = encode_utf8($_);    # CSV module doesn't do this
        }

        push @candidates, \%data;
    }

    # create two CSV files - one is just contact details and the other has the
    # extra bits in
    my @simple_fields = (
        'ID',      'Name',       'Email', 'Phone',
        'Address', 'Party Name', 'Seat Name(s)',
    );
    my @personal_fields =
      ( 'Date of Birth', 'Age', 'School', 'University', 'Gender', );
    my @all_fields = ( @simple_fields, @personal_fields );

    # create the complete file
    my $complete_csv = Text::CSV::Slurp->create(
        input       => \@candidates,
        field_order => \@all_fields,
    );

    # uplaod it to the server
    upload_to_s3_and_save_to_db(
        {
            type    => 'csv_complete',
            suffix  => 'csv',
            content => $complete_csv,
            name =>
              'CSV of candidates including contact details, schooling and age',
        }
    );

    # delete all the extra info
    foreach my $candidate (@candidates) {
        delete $candidate->{$_} for @personal_fields;
    }

    # create the simple file
    my $simple_csv = Text::CSV::Slurp->create(
        input       => \@candidates,
        field_order => \@simple_fields,
    );

    # uplaod it to the server
    upload_to_s3_and_save_to_db(
        {
            type    => 'csv_contact_only',
            suffix  => 'csv',
            content => $simple_csv,
            name    => 'CSV of candidates contact details',
        }
    );
}

##############################

sub upload_to_s3_and_save_to_db {
    my $args = shift;
    my $now  = DateTime->now;

    # s3 key
    my $file_name = sprintf(    #
        'yournextmp-%s-%s-%s.%s.gz',    #
        $args->{type}, $now->ymd(''), $now->hms(''), $args->{suffix}
    );
    my $s3_key = join(
        '/',                            #
        "data_files", $args->{type},    #
        $now->year, $now->month, $now->day,    #
        $file_name
    );

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
    $object->put($compressed);

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
