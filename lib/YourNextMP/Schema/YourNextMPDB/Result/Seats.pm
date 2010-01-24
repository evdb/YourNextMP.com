package YourNextMP::Schema::YourNextMPDB::Result::Seats;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("seats");
__PACKAGE__->add_columns(
    "code",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
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
    "name",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
);
__PACKAGE__->set_primary_key("code");
__PACKAGE__->add_unique_constraint( "name", ["name"] );
__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacies",
    { "foreign.seat" => "self.code" },
);
__PACKAGE__->has_many(
    "users",
    "YourNextMP::Schema::YourNextMPDB::Result::Users",
    { "foreign.constituency" => "self.code" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Louy1jRqP+iHd4nix3z9bA

__PACKAGE__->many_to_many(
    candidates => 'candidacies',
    'candidate'
);

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Links",
    { "foreign.code" => "self.code" },
);

1;
