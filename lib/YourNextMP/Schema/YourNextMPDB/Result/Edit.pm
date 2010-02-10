package YourNextMP::Schema::YourNextMPDB::Result::Edit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Edit

=cut

__PACKAGE__->table("edits");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('edits_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 source_table

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 100

=head2 source_id

  data_type: bigint
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

=head2 edited

  data_type: double precision
  default_value: undef
  is_nullable: 0

=head2 edit_type

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 10

=head2 data

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 user_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 comment

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        default_value     => "nextval('edits_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "source_table",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 100,
    },
    "source_id",
    { data_type => "bigint", default_value => undef, is_nullable => 0 },
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
    "edited",
    {
        data_type     => "double precision",
        default_value => undef,
        is_nullable   => 0,
    },
    "edit_type",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 10,
    },
    "data",
    { data_type => "text", default_value => undef, is_nullable => 0 },
    "user_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "comment",
    { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "YourNextMP::Schema::YourNextMPDB::Result::User",
    { id        => "user_id" },
    { join_type => "LEFT" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 23:00:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mUl9hn9oyDm9ewu5k1GfQQ

sub _store_edits { 0; }

__PACKAGE__->resultset_attributes( { order_by => ['edited'] } );

use JSON;
use Time::HiRes qw(time);

__PACKAGE__->inflate_column(
    'data',
    {
        inflate => sub { JSON->new->decode( $_[0] ) },
        deflate => sub { JSON->new->pretty->encode( $_[0] ) },
    }
);

sub insert {
    my $self = shift;

    my $now = time;
    $self->edited($now);

    my $result = $self->next::method(@_);

    return $result;
}

1;
