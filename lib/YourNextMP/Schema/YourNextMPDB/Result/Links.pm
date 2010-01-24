package YourNextMP::Schema::YourNextMPDB::Result::Links;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("links");
__PACKAGE__->add_columns(
    "id",
    {
        data_type     => "BIGINT",
        default_value => undef,
        is_nullable   => 0,
        size          => 20
    },
    "code",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "url",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => 65535,
    },
    "title",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => 65535,
    },
    "created",
    {
        data_type     => "DATETIME",
        default_value => undef,
        is_nullable   => 0,
        size          => 19,
    },
    "updated",
    {
        data_type     => "DATETIME",
        default_value => undef,
        is_nullable   => 0,
        size          => 19,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "id", ["id"] );

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ELJLClRizDc5VRkceg8FRA

1;
