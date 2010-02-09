package YourNextMP::Schema::YourNextMPDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 roles

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 created

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 updated

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 openid_identifier

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 email

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 email_confirmed

  data_type: boolean
  default_value: false
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 postcode

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 10

=head2 seat_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 copyright_granted

  data_type: timestamp without time zone
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
    "roles",
    { data_type => "text", default_value => undef, is_nullable => 1 },
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
    "openid_identifier",
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
    "email_confirmed",
    { data_type => "boolean", default_value => "false", is_nullable => 0 },
    "name",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "postcode",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 10,
    },
    "seat_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "copyright_granted",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 1,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "users_email_key", ["email"] );
__PACKAGE__->add_unique_constraint( "users_openid_identifier_key",
    ["openid_identifier"] );

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { "foreign.user_id" => "self.id" },
);

=head2 seat

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Seat>

=cut

__PACKAGE__->belongs_to(
    "seat",
    "YourNextMP::Schema::YourNextMPDB::Result::Seat",
    { id        => "seat_id" },
    { join_type => "LEFT" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 14:54:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dTYuF+c5lclEWMrgLmYSyA

=head2 screen_name

    $screen_name = $user->screen_name(  );

Returns either the user's name or 'Anonymous User'.

=cut

sub screen_name {
    return $_[0]->name || 'Anonymous User';
}

1;
