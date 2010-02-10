package YourNextMP::Schema::YourNextMPDB::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Session

=cut

__PACKAGE__->table("sessions");

=head1 ACCESSORS

=head2 id

  data_type: character
  default_value: undef
  is_nullable: 0
  size: 72

=head2 session_data

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 expires

  data_type: integer
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
        data_type     => "character",
        default_value => undef,
        is_nullable   => 0,
        size          => 72,
    },
    "session_data",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "expires",
    { data_type => "integer", default_value => undef, is_nullable => 1 },
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

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 19:36:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bvBbPRpvbFH9nwatXgQMsw

sub _store_edits { 0; }

1;
