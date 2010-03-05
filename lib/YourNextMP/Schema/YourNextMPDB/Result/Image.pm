package YourNextMP::Schema::YourNextMPDB::Result::Image;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Image

=cut

__PACKAGE__->table("images");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 source_url

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 small

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 medium

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 large

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 original

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 200

=head2 created

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 updated

  data_type: timestamp without time zone
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
    "source_url",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "small",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
    },
    "medium",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
    },
    "large",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
    },
    "original",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 200,
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "images_source_url_key", ["source_url"] );

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { "foreign.image_id" => "self.id" },
);

=head2 parties

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Party>

=cut

__PACKAGE__->has_many(
    "parties",
    "YourNextMP::Schema::YourNextMPDB::Result::Party",
    { "foreign.image_id" => "self.id" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 19:36:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vVIctUSHn6Jqm147RVhbDw

use YourNextMP;

sub public_fields {
    return ( 'small_url', 'medium_url', 'large_url' );
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

sub suffix {
    my $self   = shift;
    my $format = shift;
    my @meta   = split /,/, $self->$format, 3;
    return $meta[2];
}

sub key_for {
    my $self   = shift;
    my $format = shift;
    return $self->path_to_image( $self->id, $format, $self->suffix($format) );
}

sub path_to_image {
    my $class  = shift;
    my $id     = shift;
    my $format = shift;
    my $suffix = shift;

    $id = sprintf '%09s', $id;
    my @last_digits = $id =~ m{ (\d{2}) (\d{2}) $ }xmsg;

    return join '/',            #
      'images',                 # section
      @last_digits,             # partitioning
      "$id-$format.$suffix";    # filename
}

sub full_path_to_image {
    my $self   = shift;
    my $format = shift;

    YourNextMP::Schema::YourNextMPDB::ResultSet::Image    #
      ->store_dir                                         #
      ->file( $self->key_for($format) )                   #
      ->stringify;

}

sub delete {
    my $self = shift;

    my @paths_to_delete =                                 #
      map { $self->full_path_to_image($_) }               #
      qw(original small medium large);

    my $result = $self->next::method();

    unlink @paths_to_delete;

    return $result;
}

sub _s3_url {
    my $self   = shift;
    my $format = shift;

    return
        'http://'
      . YourNextMP->config->{aws}{public_bucket_name}
      . '.s3.amazonaws.com/'
      . $self->key_for($format);
}

sub small_url  { $_[0]->_s3_url('small') }
sub medium_url { $_[0]->_s3_url('medium') }
sub large_url  { $_[0]->_s3_url('large') }

1;

