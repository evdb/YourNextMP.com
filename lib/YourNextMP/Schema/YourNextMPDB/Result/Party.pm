package YourNextMP::Schema::YourNextMPDB::Result::Party;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Party

=cut

__PACKAGE__->table("parties");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 80

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
  is_nullable: 0
  size: 80

=head2 electoral_commision_id

  data_type: integer
  default_value: undef
  is_nullable: 1

=head2 image_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
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
        is_nullable   => 1,
        size          => 80,
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
        is_nullable   => 0,
        size          => 80,
    },
    "electoral_commision_id",
    { data_type => "integer", default_value => undef, is_nullable => 1 },
    "image_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "parties_name_key", ["name"] );
__PACKAGE__->add_unique_constraint(
    "parties_electoral_commision_id_key",
    ["electoral_commision_id"],
);
__PACKAGE__->add_unique_constraint( "parties_code_key", ["code"] );

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { "foreign.party" => "self.id" },
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

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-02 14:55:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kdBtxsMYhg0LUqlJnhQQOQ

__PACKAGE__->resultset_attributes( { order_by => ['name'] } );

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Link",
    { "foreign.source" => "self.id" },
);

1;
