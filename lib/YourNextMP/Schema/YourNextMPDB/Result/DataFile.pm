package YourNextMP::Schema::YourNextMPDB::Result::DataFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::DataFile

=cut

__PACKAGE__->table("data_files");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: SCALAR(0xa0909c)
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 type

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 40

=head2 s3_key

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

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
    "name",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
    },
    "type",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 40,
    },
    "s3_key",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
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
__PACKAGE__->add_unique_constraint( "data_files_s3_key_key", ["s3_key"] );

# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-03-24 13:14:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MOqwR7S1chH3zZgJUjxtiA

sub _store_edits { 0; }

__PACKAGE__->resultset_attributes( { order_by => ['created DESC'] } );

1;
