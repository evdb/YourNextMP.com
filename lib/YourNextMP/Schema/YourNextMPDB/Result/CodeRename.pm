package YourNextMP::Schema::YourNextMPDB::Result::CodeRename;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
  "+YourNextMP::Schema::YourNextMPDB::Base::Component",
  "InflateColumn::DateTime",
);

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::CodeRename

=cut

__PACKAGE__->table("code_renames");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa100e8)
  is_auto_increment: 1
  is_nullable: 0

=head2 old_code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 new_code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    default_value     => \"nextval('global_id_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "old_code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 80,
  },
  "new_code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 80,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-04-19 13:45:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xdCNJDRwzg/79gkeawxlQw
# These lines were loaded from '/var/folders/Ze/ZeEj4pP5FW0ni7ZVhcM-aU+++TI/-Tmp-/dbichzBo/YourNextMP/Schema/YourNextMPDB/Result/CodeRename.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

package YourNextMP::Schema::YourNextMPDB::Result::CodeRename;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
  "+YourNextMP::Schema::YourNextMPDB::Base::Component",
  "InflateColumn::DateTime",
);

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::CodeRename

=cut

__PACKAGE__->table("code_renames");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa100e8)
  is_auto_increment: 1
  is_nullable: 0

=head2 old_code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 new_code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    default_value     => \"nextval('global_id_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "old_code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 80,
  },
  "new_code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 80,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-04-19 13:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:92VKonG/AM/kmZbWp5HWXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
# End of lines loaded from '/var/folders/Ze/ZeEj4pP5FW0ni7ZVhcM-aU+++TI/-Tmp-/dbichzBo/YourNextMP/Schema/YourNextMPDB/Result/CodeRename.pm' 


# You can replace this text with custom content, and it will be preserved on regeneration
1;
