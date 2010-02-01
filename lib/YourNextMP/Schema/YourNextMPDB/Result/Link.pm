package YourNextMP::Schema::YourNextMPDB::Result::Link;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Link

=cut

__PACKAGE__->table("links");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 url

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 title

  data_type: text
  default_value: undef
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
        is_nullable   => 0,
        size          => 80,
    },
    "url",
    { data_type => "text", default_value => undef, is_nullable => 0 },
    "title",
    { data_type => "text", default_value => undef, is_nullable => 0 },
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

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-01 14:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bNFahqgdRwwjk5pUuAnL5w

1;
