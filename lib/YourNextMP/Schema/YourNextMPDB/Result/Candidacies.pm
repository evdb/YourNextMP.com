package YourNextMP::Schema::YourNextMPDB::Result::Candidacies;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("candidacies");
__PACKAGE__->add_columns(
    "candidate",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "seat",
    {
        data_type     => "VARCHAR",
        default_value => "oo",
        is_nullable   => 0,
        size          => 80
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
__PACKAGE__->set_primary_key( "candidate", "seat" );
__PACKAGE__->belongs_to(
    "seat",
    "YourNextMP::Schema::YourNextMPDB::Result::Seats",
    { code => "seat" },
);
__PACKAGE__->belongs_to(
    "candidate",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidates",
    { code => "candidate" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OYCkdM6nMLpgmScbnrGSSw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
