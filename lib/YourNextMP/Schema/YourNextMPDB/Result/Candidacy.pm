package YourNextMP::Schema::YourNextMPDB::Result::Candidacy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Candidacy

=cut

__PACKAGE__->table("candidacies");

=head1 ACCESSORS

=head2 candidate_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 seat_id

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

=head2 id

  data_type: integer
  default_value: nextval('candidacies_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "candidate_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "seat_id",
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
    "id",
    {
        data_type         => "integer",
        default_value     => "nextval('candidacies_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
    "candidacies_seat_id_candidate_id_key",
    [ "seat_id", "candidate_id" ],
);

=head1 RELATIONS

=head2 seat

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Seat>

=cut

__PACKAGE__->belongs_to(
    "seat",
    "YourNextMP::Schema::YourNextMPDB::Result::Seat",
    { id => "seat_id" }, {},
);

=head2 candidate

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
    "candidate",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { id => "candidate_id" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 23:00:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BdcLOGq9MZzKv8lAdc8tRg

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

1;
