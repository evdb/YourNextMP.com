package YourNextMP::Schema::YourNextMPDB::Result::Link;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Link

=cut

__PACKAGE__->table("links");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 url

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 title

  data_type: text
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

=head2 summary

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 link_type

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 10

=head2 published

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        default_value     => "nextval('global_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "url",
    { data_type => "text", default_value => undef, is_nullable => 0 },
    "title",
    { data_type => "text", default_value => undef, is_nullable => 0 },
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
    "summary",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "link_type",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 10,
    },
    "published",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 1,
    },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 link_relations

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::LinkRelation>

=cut

__PACKAGE__->has_many(
    "link_relations",
    "YourNextMP::Schema::YourNextMPDB::Result::LinkRelation",
    { "foreign.link_id" => "self.id" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-23 12:11:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3XjbCGAM+ddPpTR207EcRw

sub new {
    my $class = shift;
    my $args  = shift;

    $args->{link_type} ||= 'info';

    return $class->next::method( $args, @_ );
}

=head2 edits

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Edit>

=cut

__PACKAGE__->has_many(
    "edits",
    "YourNextMP::Schema::YourNextMPDB::Result::Edit",
    { "foreign.source_id" => "self.id" },
    { cascade_delete      => 0 },
);

=head2 candidates, parties, seats

Type: many_to_many

=cut

__PACKAGE__->many_to_many( candidates => link_relations => 'candidate' );
__PACKAGE__->many_to_many( parties    => link_relations => 'party' );
__PACKAGE__->many_to_many( seats      => link_relations => 'seat' );

=head2 abbreviated_url

    $abbreviated_url = $link->abbreviated_url( $max_length );

Abbreviate the url so that it will fit in the $max_length (default 40 chars).
Chops out bits between the host and filename until it fits or there is none
left. Also ditches params etc.

=cut

sub abbreviated_url {
    my $self = shift;
    my $max_length = shift || 40;

    my $url = $self->url;

    # ditch the params
    $url =~ s{\?.*$}{};

    my ( $schema, $host, @parts ) = split m{/+}, $url;
    return $url unless @parts;
    my $file = pop @parts || '';

    my $joiner = undef;

    while (1) {

        $url = join '/',    #
          grep { defined }  #
          ( $host, @parts, $joiner, $file );

        last unless @parts;
        last if length($url) <= $max_length;
        $joiner = '...';
        pop @parts;
    }

    return $url if length($url) < $max_length;
    return $host;
}

=head2 type_verbose, type_icon

    $type_verbose = $link->type_verbose(  );

Returns the pretty wordy version of the type.

=cut

my %LINK_TYPE_EXTRAS = (
    info    => { verbose => 'Informational', icon => 'information', },
    news    => { verbose => 'News',          icon => 'newspaper', },
    opinion => { verbose => 'Opinion',       icon => 'comments', },
);

sub type_verbose { $_[0]->_get_extra('verbose') }
sub type_icon    { $_[0]->_get_extra('icon') }

sub _get_extra {
    my ( $self, $extra ) = @_;

    return $LINK_TYPE_EXTRAS{ $self->link_type }{$extra}
      || die "Unknown type for extra '$extra': " . $self->link_type;
}

1;
