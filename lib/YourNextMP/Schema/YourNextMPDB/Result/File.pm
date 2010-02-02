package YourNextMP::Schema::YourNextMPDB::Result::File;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::File

=cut

__PACKAGE__->table("files");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 md5

  data_type: character
  default_value: undef
  is_nullable: 0
  size: 32

=head2 format

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 created

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 updated

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 data

  data_type: bytea
  default_value: undef
  is_nullable: 0

=head2 mime_type

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 source

  data_type: text
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
    "md5",
    {
        data_type     => "character",
        default_value => undef,
        is_nullable   => 0,
        size          => 32,
    },
    "format",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
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
    "data",
    { data_type => "bytea", default_value => undef, is_nullable => 0 },
    "mime_type",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "source",
    { data_type => "text", default_value => undef, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "files_md5_key", [ "md5", "format" ] );

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-02 11:06:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6NAmbasjUE1L2aog8fcqVQ

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
