package YourNextMP::Schema::YourNextMPDB::Result::Supporter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Supporter

=cut

__PACKAGE__->table("supporters");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa104f4)
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 token

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 level

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 website

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 logo_url

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 summary

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

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        default_value     => \"nextval('global_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "user_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "name",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
    },
    "code",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "token",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
    },
    "level",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
    },
    "website",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "logo_url",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "summary",
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "supporters_token_key", ["token"] );
__PACKAGE__->add_unique_constraint( "supporters_code_key",  ["code"] );
__PACKAGE__->add_unique_constraint( "supporters_name_key",  ["name"] );

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "YourNextMP::Schema::YourNextMPDB::Result::User",
    { id => "user_id" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-03-24 09:21:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xbwe8L/AOAj2153B5D4imA

1;
