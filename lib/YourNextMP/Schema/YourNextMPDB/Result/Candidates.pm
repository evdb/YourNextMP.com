package YourNextMP::Schema::YourNextMPDB::Result::Candidates;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("candidates");
__PACKAGE__->add_columns(
    "code",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "user",
    {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 1,
        size          => 11
    },
    "party",
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
        is_nullable   => 1,
        size          => 200,
    },
    "email",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "phone",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "fax",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "address",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "photo",
    {
        data_type     => "CHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 32
    },
    "bio",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 1,
        size          => 65535,
    },
);
__PACKAGE__->set_primary_key("code");
__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacies",
    { "foreign.candidate" => "self.code" },
);
__PACKAGE__->belongs_to(
    "user",
    "YourNextMP::Schema::YourNextMPDB::Result::Users",
    { id => "user" },
);
__PACKAGE__->belongs_to(
    "party",
    "YourNextMP::Schema::YourNextMPDB::Result::Parties",
    { code => "party" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Kxs+OxRXJzH40hw2Q6oA/g

__PACKAGE__->many_to_many(
    seats => 'candidacies',
    'seat'
);

__PACKAGE__->has_many(
    "photos",
    "YourNextMP::Schema::YourNextMPDB::Result::Files",
    {
        "foreign.md5" => "self.photo",    #
    },
);

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Links",
    { "foreign.code" => "self.code" },
);

sub original_photo {
    my $self = shift;
    return $self->photos( { format => 'original' } )->first;
}

1;
