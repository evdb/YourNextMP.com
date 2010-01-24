package YourNextMP::Schema::YourNextMPDB::Result::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
    "id",
    {
        data_type     => "INT",
        default_value => undef,
        is_nullable   => 0,
        size          => 11
    },
    "roles",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 1,
        size          => 65535,
    },
    "openid_identifier",
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
    "email_confirmed",
    { data_type => "TINYINT", default_value => 0, is_nullable => 0, size => 1 },
    "name",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "postcode",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
        size          => 10,
    },
    "constituency",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 1,
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "email", ["email"] );
__PACKAGE__->add_unique_constraint( "openid_identifier",
    ["openid_identifier"] );
__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidates",
    { "foreign.user" => "self.id" },
);
__PACKAGE__->belongs_to(
    "constituency",
    "YourNextMP::Schema::YourNextMPDB::Result::Seats",
    { code => "constituency" },
);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36

=head2 screen_name

    $screen_name = $user->screen_name(  );

Returns either the user's name or 'Anonymous User'.

=cut

sub screen_name {
    return $_[0]->name || 'Anonymous User';
}

1;
