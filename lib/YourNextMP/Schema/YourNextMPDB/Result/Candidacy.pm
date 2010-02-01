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

=head2 candidate

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 seat

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

=cut

__PACKAGE__->add_columns(
    "candidate",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "seat",
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
);
__PACKAGE__->add_unique_constraint( "candidacies_candidate_key",
    [ "candidate", "seat" ] );

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
    "candidate",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { id => "candidate" }, {},
);

=head2 seat

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Seat>

=cut

__PACKAGE__->belongs_to(
    "seat",
    "YourNextMP::Schema::YourNextMPDB::Result::Seat",
    { id => "seat" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-01 14:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LzqpiGehQN0kMUmCfPVU3A

# You can replace this text with custom content, and it will be preserved on regeneration
1;
