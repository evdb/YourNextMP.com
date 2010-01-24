package YourNextMP::Schema::YourNextMPDB::Result::Files;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", "Core", );
__PACKAGE__->table("files");
__PACKAGE__->add_columns(
    "md5",
    {
        data_type     => "CHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 32
    },
    "format",
    {
        data_type     => "VARCHAR",
        default_value => "",
        is_nullable   => 0,
        size          => 20
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
    "data",
    {
        data_type     => "LONGBLOB",
        default_value => undef,
        is_nullable   => 0,
        size          => 4294967295,
    },
    "mime_type",
    {
        data_type     => "VARCHAR",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "source",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => 65535,
    },
);
__PACKAGE__->set_primary_key( "md5", "format" );

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O3SiVSxj/+IHs+KePPoWRg

use Image::Imlib2;
use File::Temp;
use Carp;

sub imlib_image {
    my $self = shift;

    my $mime_type = $self->mime_type;
    croak "Can't call imlib_image on a non-image file"
      if $mime_type !~ m{image/(jpe?g|gif|png)};
    my $suffix = ".$1";

    my $tmp = File::Temp->new( SUFFIX => $suffix );
    print $tmp $self->data;
    $tmp->close;

    my $image = Image::Imlib2->load( $tmp->filename );
    return $image;
}

1;
