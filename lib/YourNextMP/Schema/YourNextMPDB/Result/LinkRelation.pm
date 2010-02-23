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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aaQZi7MeAhD7YbP/Nd8zTw
# These lines were loaded from '/var/folders/Ze/ZeEj4pP5FW0ni7ZVhcM-aU+++TI/-Tmp-/dbicjWDd/YourNextMP/Schema/YourNextMPDB/Result/LinkRelation.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-23 12:11:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PwwURpHyz3vmZuSLdI6mNQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;

# End of lines loaded from '/var/folders/Ze/ZeEj4pP5FW0ni7ZVhcM-aU+++TI/-Tmp-/dbicjWDd/YourNextMP/Schema/YourNextMPDB/Result/LinkRelation.pm'

# You can replace this text with custom content, and it will be preserved on regeneration
1;
