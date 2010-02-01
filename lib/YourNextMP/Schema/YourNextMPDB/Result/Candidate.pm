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
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 user_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 party

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

=head2 photo

  data_type: character
  default_value: undef
  is_nullable: 1
  size: 32

=head2 bio

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        default_value     => "nextval('global_id_seq'::regclass)",
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
    "user_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "party",
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
    "photo",
    {
        data_type     => "character",
        default_value => undef,
        is_nullable   => 1,
        size          => 32,
    },
    "bio",
    { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "candidates_code_key", ["code"] );

=head1 RELATIONS

=head2 candidacies

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidacy>

=cut

__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacy",
    { "foreign.candidate" => "self.id" },
);

=head2 user

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "YourNextMP::Schema::YourNextMPDB::Result::User",
    { id        => "user_id" },
    { join_type => "LEFT" },
);

=head2 party

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Party>

=cut

__PACKAGE__->belongs_to(
    "party",
    "YourNextMP::Schema::YourNextMPDB::Result::Party",
    { id => "party" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-01 14:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qJb154aomi2aynSNoupPaw

__PACKAGE__->many_to_many(
    seats => 'candidacies',
    'seat'
);

__PACKAGE__->has_many(
    "photos",
    "YourNextMP::Schema::YourNextMPDB::Result::File",
    {
        "foreign.md5" => "self.photo",    #
    },
);

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Link",
    { "foreign.code" => "self.code" },
);

sub original_photo {
    my $self = shift;
    return $self->photos( { format => 'original' } )->first;
}

sub insert {
    my $self = shift;

    unless ( $self->code ) {
        $self->code(
            $self->result_source->resultset->name_to_code( $self->name ) );
    }

    # my $now = DateTime->now();
    # $self->created($now);
    # $self->updated($now);

    return $self->next::method(@_);
}

1;
