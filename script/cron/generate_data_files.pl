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
use IO::Interactive qw(interactive);

sub burp ( @ ) { printf {interactive} @_; }

generate_main_json();
generate_links_json();
generate_csv_files();

# generate_images_json();

sub generate_main_json {

    burp "Generating main json\n";

    # Fetch all candidates, parties, constituencies and candidacies
    _generate_json(
        {
            fetch_spec => {
                Candidate => {
                    fields => [
                        'id',         'code',
                        'status',     'party_id',
                        'created',    'updated',
                        'name',       'email',
                        'phone',      'fax',
                        'address',    'image_id',
                        'dob',        'gender',
                        'school',     'university',
                        'positions',  'status',
                        'birthplace', 'votes',
                    ],
                    where => {},
                },
                Party => {
                    fields => [
                        'id',   'code', 'created', 'updated',
                        'name', 'image_id',
                    ],
                    where => {},
                },
                Seat => {
                    fields => [
                        'id', 'code', 'created', 'updated', 'name',
                        'nomination_url', 'nominations_entered',
                    ],
                    where => {},
                },
                Candidacy => {
                    fields => [
                        'candidate_id', 'seat_id', 'created', 'updated', 'id',
                    ],
                    where => {},
                },
            },
            s3_details => {
                type   => 'json_main',
                suffix => 'json',
                name   => 'JSON of candidates, candidacies, parties and seats',
            },
        }
    );
}

sub generate_links_json {

    burp "Generating links json\n";

    # Fetch all candidates, parties, constituencies and candidacies
    _generate_json(
        {
            fetch_spec => {
                Link => {
                    fields => [
                        'id',      'url',                                  #
                        'title',   'summary', 'published', 'link_type',    #
                        'created', 'updated',
                    ],
                    where => {},
                },
                LinkRelation => {
                    fields => [
                        'id',                                              #
                        'link_id', 'foreign_id', 'foreign_table',          #
                        'created', 'updated',
                    ],
                    where => {},
                },
            },
            s3_details => {
                type   => 'json_links',
                suffix => 'json',
                name =>
'JSON of links and relations to candidates, parties and seats',
            },
        }
    );
}

# sub generate_images_json {
#
#     burp "Generating images json\n";
#
# FIXME - need to select only candidate images and inflate the rows to s3 urls
#
#     # Fetch all candidates, parties, constituencies and candidacies
#     _generate_json(
#         {
#             fetch_spec => {
#                 Image => {
#                     fields => [
#                         'id',    'source_url', 'small',   'medium',
#                         'large', 'created', 'updated',
#                     ],
#                     where => {},
#                 },
#             },
#             s3_details => {
#                 type   => 'json_images',
#                 suffix => 'json',
#                 name   => 'JSON of candidate images',
#             },
#         }
#     );
# }

sub _generate_json {
    my $args       = shift;
    my $fetch_spec = $args->{fetch_spec};
    my $s3_details = $args->{s3_details};

    # Extract the data from the database
    my %data = ();
    foreach my $source ( sort keys %$fetch_spec ) {
        burp "\tfetching data from %s\n", $source;
        my $spec = $fetch_spec->{$source};
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

    # upload it to the server
    upload_to_s3_and_save_to_db( { %$s3_details, content => $json, } );
}

sub generate_csv_files {

    burp "Generating csv files\n";

    # create an array of hashes for all the candidates
    my $candidates_rs      #
      = YourNextMP         #
      ->db('Candidate')    #
      ->standing           #
      ->search( undef, { prefetch => 'party', order_by => 'me.code' } );
    my @candidates = ();

    while ( my $row = $candidates_rs->next ) {

        my $first_seat = $row->seats->first;
        next unless $first_seat;

        my %data = (
            'ID'             => $row->id,
            'Name'           => $row->name,
            'Email'          => $row->email,
            'Phone'          => $row->phone,
            'Address'        => $row->address,
            'Party Name'     => $row->party->name,
            'Seat Name(s)'   => join( ', ', $row->seat_names ),
            'Date of Birth'  => $row->dob,
            'Place of Birth' => $row->birthplace,
            'Age'            => $row->age,
            'School'         => $row->school,
            'University'     => $row->university,
            'Gender'         => $row->gender,
            'Nomination Confirmed' =>
              ( $first_seat->nominations_entered ? 'yes' : 'no' ),
            'URL' => 'http://' . YourNextMP->config->{base_host} . $row->path,
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
    my @contact_fields = (
        'ID',      'Name',       'Email', 'Phone',
        'Address', 'Party Name', 'Seat Name(s)',
    );
    my @personal_fields = (
        'Date of Birth', 'Place of Birth',
        'Age',           'School',
        'University',    'Gender',
        'Nomination Confirmed',
    );

    my @simple_fields = ( @contact_fields, 'URL' );
    my @complete_fields = ( @contact_fields, @personal_fields, 'URL' );

    # create the complete file
    my $complete_csv = Text::CSV::Slurp->create(
        input       => \@candidates,
        field_order => \@complete_fields,
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

    # upload it to the server
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
    my $uncompressed = $args->{content};
    my $compressed   = '';
    gzip \$uncompressed => \$compressed
      or die "gzip failed: $GzipError\n";

    {
        use bytes;
        my $u_length = length($uncompressed);
        my $c_length = length($compressed);

        burp "\tcompressed content: %u -> %u (%.2f%%)\n",    #
          $u_length, $c_length,                              #
          $c_length / $u_length * 100;
    }

    # upload to s3
    my $bucket = YourNextMP->s3_bucket;
    my $object = $bucket->object(
        key          => $s3_key,
        content_type => 'application/gzip',
        acl_short    => 'private',
    );
    burp "\tuploading to S3 '%s'\n", $s3_key;
    $object->put($compressed);

    # create an entry in the database
    burp "\tsaving to db '%s'\n", $s3_key;
    YourNextMP->db('DataFile')->create(
        {
            name    => $args->{name},
            type    => $args->{type},
            s3_key  => $s3_key,
            created => $now,
        }
    );
}
