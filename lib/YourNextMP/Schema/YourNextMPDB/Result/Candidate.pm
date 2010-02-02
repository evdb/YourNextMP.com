package YourNextMP::Schema::YourNextMPDB::Result::Candidate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Candidate

=cut

__PACKAGE__->table("candidates");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 80

=head2 user_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 party

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 created

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 updated

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 name

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 email

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 phone

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 fax

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 address

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 200

=head2 photo

  data_type: character
  default_value: undef
  is_nullable: 1
  size: 32

=head2 bio

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 scrape_source

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 300

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "bigint",
        default_value     => "nextval('global_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "code",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 80,
    },
    "user_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "party",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
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
    "name",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "email",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "phone",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "fax",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "address",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 200,
    },
    "photo",
    {
        data_type     => "character",
        default_value => undef,
        is_nullable   => 1,
        size          => 32,
    },
    "bio",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "scrape_source",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 300,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "candidates_code_key", ["code"] );

=head1 RELATIONS

=head2 candidacies

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidacy>

=cut

__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacy",
    { "foreign.candidate_id" => "self.id" },
);

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

=head2 party

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Party>

=cut

__PACKAGE__->belongs_to(
    "party",
    "YourNextMP::Schema::YourNextMPDB::Result::Party",
    { id => "party" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-02 11:40:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pt3tskF0Y73XlZBVYougbg

__PACKAGE__->resultset_attributes( { order_by => ['name'] } );

__PACKAGE__->many_to_many(
    seats => 'candidacies',
    'seat'
);

__PACKAGE__->has_many(
    "photos",
    "YourNextMP::Schema::YourNextMPDB::Result::File",
    {
        "foreign.md5" => "self.photo",    #
    },
);

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Link",
    { "foreign.source" => "self.id" },
);

sub original_photo {
    my $self = shift;
    return $self->photos( { format => 'original' } )->first;
}

sub insert {
    my $self = shift;

    unless ( $self->code ) {
        $self->code(
            $self->result_source->resultset->name_to_code( $self->name ) );
    }

    # my $now = DateTime->now();
    # $self->created($now);
    # $self->updated($now);

    return $self->next::method(@_);
}

use List::Util qw( first );

use Module::Pluggable
  sub_name    => 'scrapers',
  search_path => ['YourNextMP::Scrapers'],
  require     => 1,
  except      => 'YourNextMP::Scrapers::ScraperBase';

my @SCRAPERS = __PACKAGE__->scrapers;

sub update_by_scraping {
    my $self = shift;

    # Find the scraper to use
    my $scraper = _find_scraper_for( $self->scrape_source );

    # Get the data out
    my $data = $scraper->extract_candidate_data($self);

    use Data::Dumper;
    local $Data::Dumper::Sortkeys = 1;
    warn Dumper($data);

    # extract bits that are not core to the candidate
    my $photo_url = delete $data->{photo_url} || '';
    my $links     = delete $data->{links}     || [];

    # Apply the data to the candidate
    $self->update($data);

    # Make sure all the links exist
    foreach my $title ( keys %$links ) {
        my $url = $links->{$title};
        $self->find_or_create_related(
            links => {
                url   => $url,     #
                title => $title,
            }
        );
    }
    
    # If there is a photo deal with it
    if ( $photo_url) {
        
    }

}

sub _find_scraper_for {
    my $url = shift;
    return first { $_->can_do_url($url) } @SCRAPERS;
}

1;
