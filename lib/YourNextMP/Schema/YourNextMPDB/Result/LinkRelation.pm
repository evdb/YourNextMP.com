package YourNextMP::Schema::YourNextMPDB::Result::LinkRelation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::LinkRelation

=cut

__PACKAGE__->table("link_relations");

=head1 ACCESSORS

=head2 foreign_id

  data_type: bigint
  default_value: undef
  is_nullable: 0

=head2 link_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 foreign_table

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 40

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
    "foreign_id",
    { data_type => "bigint", default_value => undef, is_nullable => 0 },
    "link_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "foreign_table",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 40,
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
__PACKAGE__->set_primary_key( "foreign_id", "link_id" );

=head1 RELATIONS

=head2 link

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Link>

=cut

__PACKAGE__->belongs_to(
    "link",
    "YourNextMP::Schema::YourNextMPDB::Result::Link",
    { id => "link_id" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-23 12:11:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2P62PvqPqFq4ZDMg2WnIgg

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

__PACKAGE__->might_have(
    candidate => "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { 'foreign.id'   => 'self.foreign_id' },
    { cascade_delete => 0 }
);

__PACKAGE__->might_have(
    party => "YourNextMP::Schema::YourNextMPDB::Result::Party",
    { 'foreign.id'   => 'self.foreign_id' },
    { cascade_delete => 0 }
);

__PACKAGE__->might_have(
    seat => "YourNextMP::Schema::YourNextMPDB::Result::Seat",
    { 'foreign.id'   => 'self.foreign_id' },
    { cascade_delete => 0 }
);

1;

