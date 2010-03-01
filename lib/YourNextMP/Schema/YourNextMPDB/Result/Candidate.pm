package YourNextMP::Schema::YourNextMPDB::Result::Candidate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Candidate

=cut

__PACKAGE__->table("candidates");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa00a60)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 party_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 created

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 updated

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 email

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 phone

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 fax

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 address

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 image_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 scrape_source

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 300

=head2 can_scrape

  data_type: boolean
  default_value: SCALAR(0xa06f0c)
  is_nullable: 0

=head2 last_scraped

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        default_value     => \"nextval('global_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "code",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "party_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "created",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 0,
    },
    "updated",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 0,
    },
    "name",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "email",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "phone",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "fax",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "address",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "image_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "scrape_source",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 300,
    },
    "can_scrape",
    { data_type => "boolean", default_value => \"true", is_nullable => 0 },
    "last_scraped",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 1,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "candidates_code_key", ["code"] );
__PACKAGE__->add_unique_constraint( "candidates_scrape_source_key",
    ["scrape_source"] );

=head1 RELATIONS

=head2 bad_details

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::BadDetail>

=cut

__PACKAGE__->has_many(
    "bad_details",
    "YourNextMP::Schema::YourNextMPDB::Result::BadDetail",
    { "foreign.candidate_id" => "self.id" },
);

=head2 candidacies

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidacy>

=cut

__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacy",
    { "foreign.candidate_id" => "self.id" },
);

=head2 party

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Party>

=cut

__PACKAGE__->belongs_to(
    "party",
    "YourNextMP::Schema::YourNextMPDB::Result::Party",
    { id => "party_id" }, {},
);

=head2 image

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Image>

=cut

__PACKAGE__->belongs_to(
    "image",
    "YourNextMP::Schema::YourNextMPDB::Result::Image",
    { id        => "image_id" },
    { join_type => "LEFT" },
);

# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-26 17:55:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EHpKrJRmdXz9CFSn5mqpNw

__PACKAGE__->resultset_attributes( { order_by => ['code'] } );

__PACKAGE__->has_many(
    "link_relations",
    "YourNextMP::Schema::YourNextMPDB::Result::LinkRelation",
    { "foreign.foreign_id" => "self.id" },
);

__PACKAGE__->many_to_many( links => link_relations => 'link' );

__PACKAGE__->many_to_many( seats => candidacies => 'seat' );

=head2 edits

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Edit>

=cut

__PACKAGE__->has_many(
    "edits",
    "YourNextMP::Schema::YourNextMPDB::Result::Edit",
    { "foreign.source_id" => "self.id" },
    { cascade_delete      => 0 },
);

sub insert {
    my $self = shift;
    my $args = shift;

    unless ( $self->code ) {
        $self->code(
            $self->result_source->resultset->name_to_code( $self->name ) );
    }

    my $result = $self->next::method( $args, @_ );

    $self->update_bad_details;

    return $result;
}

sub update {
    my $self   = shift;
    my $args   = shift;
    my $result = $self->next::method( $args, @_ );

    $self->update_bad_details;

    return $result;
}

sub delete {
    my $self = shift;
    my $args = shift;

    $self->bad_details->delete;

    return $self->next::method( $args, @_ );
}

use YourNextMP::Scrapers::ScraperBase;
use DateTime;

sub update_by_scraping {
    my $self = shift;

    # Find the scraper to use
    my $scraper = YourNextMP::Scrapers::ScraperBase    #
      ->find_candidate_scraper( $self->scrape_source );

    # Get the data out
    my $data = $scraper->extract_candidate_data($self);

    # use Data::Dumper;
    # local $Data::Dumper::Sortkeys = 1;
    # warn Dumper($data);

    # extract bits that are not core to the candidate
    my $photo_url = delete $data->{photo_url} || '';
    my $seat_name = delete $data->{seat}      || '';
    my $links     = delete $data->{links}     || {};

    # Apply the data to the candidate
    $data->{last_scraped} = DateTime->now;
    $self->update($data);

    my $links_rs = $self->result_source->schema->resultset('Link');

    # Make sure all the links exist
    foreach my $title ( keys %$links ) {
        my $url  = $links->{$title};
        my $link = $links_rs->find_or_create(
            url       => $url,     #
            title     => $title,
            link_type => 'info',
        );
        $self->find_or_create_related(
            link_relations => {
                link_id       => $link->id,
                foreign_table => 'candidates',
            }
        );
    }

    # If there is a photo deal with it
    if ($photo_url) {

        my $image = $self         #
          ->result_source         #
          ->schema                #
          ->resultset('Image')    #
          ->find_or_create( { source_url => $photo_url, } );

        for (1) {
            last if !$image;
            last if $self->image_id && $self->image_id == $image->id;
            $self->update( { image => $image } );
        }
    }

    # If there is a seat set it
    # Find the seat.
    if ($seat_name) {

        my $seat_rs = $self->result_source->schema->resultset('Seat');

        if ( my $seat = $seat_rs->find( { code_from_name => $seat_name } ) ) {

            # Make sure that the candidate is assigned to their seat
            $self->add_to_candidacies( { seat => $seat } )
              unless $self->count_related(
                candidacies => { seat_id => $seat->id } );
        }
        else {
            warn sprintf 'Can not find seat "%s" from "%s"', $seat_name,
              $self->scrape_source;
        }
    }

}

=head2 update_bad_details

    $candidate->update_bad_details;

Look at the details that we have and create or delete the entries in the bad
details table to match.

=cut

sub update_bad_details {
    my $self             = shift;
    my @details_to_check = qw(email phone fax address);

    foreach my $detail (@details_to_check) {
        my $check_method = "_find_detail_issue_for_$detail";

        my $issue = !$self->$detail    # check if it is there
          ? 'missing'                  # if not then 'missing'
          : $self->$check_method;      # otherwise do deeper check

        if ($issue) {
            $self->update_or_create_related(
                bad_details => {
                    issue  => $issue,
                    detail => $detail,
                }
            );
        }
        else {
            $self->bad_details( { detail => $detail, } )->delete;
        }
    }

    return 1;
}

sub _find_detail_issue_for_email {
    my $self = shift;
    my $val  = $self->email;
    return 'parliament' if $self->is_parliamentary_email($val);
    return '';
}

sub _find_detail_issue_for_phone {
    my $self = shift;
    my $val  = $self->phone;
    return 'parliament' if $self->is_parliamentary_number($val);
    return '';
}

sub _find_detail_issue_for_fax {
    my $self = shift;
    my $val  = $self->fax;
    return 'parliament' if $self->is_parliamentary_number($val);
    return '';
}

sub _find_detail_issue_for_address {
    my $self = shift;
    my $val  = $self->address;

    return 'parliament' if $self->is_parliamentary_address($val);

    return '';
}

sub is_parliamentary_email {
    my $class = shift;
    my $email = shift;
    return $email =~ m{\@parliament\.uk}i;
}

sub is_parliamentary_number {
    my $class  = shift;
    my $number = shift;
    $number =~ s{[\D+]}{}g;
    return $number =~ m{ \A (?: 0 | \+44 ) 20 7219 }x;
}

sub is_parliamentary_address {
    my $class   = shift;
    my $address = shift;
    return $address =~ m{ sw1a \s* 0aa }ixms;
}

=head2 seat_names

    @seat_names = $candidate->seat_names(  );

Returns a list of all the seat names for this candidate

=cut

sub seat_names {
    my $self = shift;

    return map { $_->name } $self->seats;

}

1;
