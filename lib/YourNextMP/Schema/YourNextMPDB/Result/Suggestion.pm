package YourNextMP::Schema::YourNextMPDB::Result::Suggestion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Suggestion

=cut

__PACKAGE__->table("suggestions");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa0717c)
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 email

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 ip

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 20

=head2 referer

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 suggestion

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 type

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 status

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

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
        is_nullable    => 1,
    },
    "email",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "ip",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 20,
    },
    "referer",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "suggestion",
    { data_type => "text", default_value => undef, is_nullable => 0 },
    "type",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
    },
    "status",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
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
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-25 15:59:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vk/A75DGKsn5YtLp7WtZUA

sub _store_edits { 0; }

1;

