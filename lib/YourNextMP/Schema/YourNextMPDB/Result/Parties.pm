package YourNextMP::Schema::YourNextMPDB::Result::Parties;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("parties");
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
    "electoral_commision_id",
    {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 1,
        size          => 11
    },
    "emblem",
    {
        data_type     => "CHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 32
    },
);
__PACKAGE__->set_primary_key("code");
__PACKAGE__->add_unique_constraint( "electoral_commision_id",
    ["electoral_commision_id"] );
__PACKAGE__->add_unique_constraint( "name", ["name"] );
__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidates",
    { "foreign.party" => "self.code" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EJhSLR6cQ0GISVQzCyOs+A

__PACKAGE__->has_many(
    "emblems",
    "YourNextMP::Schema::YourNextMPDB::Result::Files",
    {
        "foreign.md5" => "self.emblem",    #
    },
);

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Links",
    { "foreign.code" => "self.code" },
);

sub original_emblem {
    my $self = shift;
    return $self->emblems( { format => 'original' } )->first;
}

1;
