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
        inflate => sub { JSON->new->utf8->decode( $_[0] ) },
        deflate => sub {
            my $data = $_[0];
            $_ .= '' for grep { ref $_ } values %$data;
            JSON->new->pretty->canonical->utf8->encode($data);
        },
    }
);

sub insert {
    my $self = shift;

    my $now = time;
    $self->edited($now);

    my $result = $self->next::method(@_);

    return $result;
}

sub previous_edit {
    my $self = shift;
    my $rs   = $self->result_source->resultset;
    return $rs->search(
        {
            source_table => $self->source_table,
            source_id    => $self->source_id,
            created      => { '<' => $self->created }
        },
        { order_by => 'created desc' }
    )->first;
}

use List::MoreUtils 'uniq';

sub deltas {
    my $self          = shift;
    my $previous_edit = $self->previous_edit;

    my $after_data  = $self->data;
    my $before_data = $previous_edit ? $previous_edit->data : {};
    my @keys        = uniq sort ( keys %$before_data, keys %$after_data );

    my @deltas = ();

    # FIXME - replace with public fields
    my %skip_fields = map { $_ => 1 } qw( created updated can_scrape );

    foreach my $key (@keys) {
        next if $skip_fields{$key};
        my $before = $before_data->{$key} || '';
        my $after  = $after_data->{$key}  || '';
        next if $before eq $after;

        push @deltas,
          {
            field  => $key,
            before => $before,
            after  => $after,
          };
    }

    return \@deltas;
}
1;
