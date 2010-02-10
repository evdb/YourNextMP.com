package YourNextMP::Schema::YourNextMPDB::Result::Party;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Party

=cut

__PACKAGE__->table("parties");

=head1 ACCESSORS

=head2 id

  data_type: bigint
  default_value: nextval('global_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 code

  data_type: character varying
  default_value: undef
  is_nullable: 1
  size: 80

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
  is_nullable: 0
  size: 80

=head2 electoral_commision_id

  data_type: integer
  default_value: undef
  is_nullable: 1

=head2 image_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
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
    "code",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 1,
        size          => 80,
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
        is_nullable   => 0,
        size          => 80,
    },
    "electoral_commision_id",
    { data_type => "integer", default_value => undef, is_nullable => 1 },
    "image_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 1,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "parties_name_key", ["name"] );
__PACKAGE__->add_unique_constraint(
    "parties_electoral_commision_id_key",
    ["electoral_commision_id"],
);
__PACKAGE__->add_unique_constraint( "parties_code_key", ["code"] );

=head1 RELATIONS

=head2 candidates

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->has_many(
    "candidates",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { "foreign.party_id" => "self.id" },
);

=head2 image

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Image>

=cut

__PACKAGE__->belongs_to(
    "image",
    "YourNextMP::Schema::YourNextMPDB::Result::Image",
    { id        => "image_id" },
    { join_type => "LEFT" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 19:36:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:podizve5l1oIv9c4XYctbA

__PACKAGE__->resultset_attributes( { order_by => ['code'] } );

__PACKAGE__->has_many(
    "links",
    "YourNextMP::Schema::YourNextMPDB::Result::Link",
    { "foreign.source" => "self.id" },
);

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

=head2 scrape_candidates

    $party->scrape_candidates();

Scrape the candidates for this party from their website. Any candidates found
are added to the database and can be filled in properly using
C<update_by_scraping> on the candidate object later.

=cut

use YourNextMP::Scrapers::ScraperBase;

sub scrape_candidates {
    my $self = shift;

    # Find the scraper to use
    my $scraper = YourNextMP::Scrapers::ScraperBase    #
      ->find_candidate_list_scraper( $self->code );

    # If no scraper return (not all parties can be sraped)
    return unless $scraper;

    # Scrape the list and get the data back
    my $candidates = $scraper->extract_candidate_list();

    # use Data::Dumper;
    # local $Data::Dumper::Sortkeys = 1;
    # warn Dumper($candidates);

    # Load resultsets we will need
    my $seat_rs = $self->result_source->schema->resultset('Seat');
    my $can_rs  = $self->result_source->schema->resultset('Candidate');

    foreach my $can (@$candidates) {

        # Get some clean data out
        my $code          = $can_rs->name_to_code( $can->{name} );
        my $name          = $can_rs->clean_name( $can->{name} );
        my $scrape_source = $can->{scrape_source};

        # We don't care if candidates already exist - just want to add new ones.
        # Don't trust that the code has not changed so find on scrape_source
        my $candidate =
             $can_rs->find( { scrape_source => $scrape_source } )
          || $can_rs->find( { code          => $code } )
          || $can_rs->create(
            {
                code          => $code,
                name          => $name,
                scrape_source => $scrape_source,
                party         => $self,
            }
          );

        if ( !$candidate->scrape_source ) {

            # we have a scrape_source for an existing candidate - add it
            $candidate->update( { scrape_source => $scrape_source } );
        }
        elsif ( $candidate->scrape_source ne $scrape_source ) {

            # Sanity check that the scrape_source has not changed
            warn sprintf
              "SCRAPE SOURCE HAS CHANGED!! id: %s, from '%s' to '%s'",
              $candidate->id, $candidate->scrape_source, $scrape_source;
        }

        # Find the seat.
        if ( my $seat_name = delete $can->{seat} ) {
            my $seat = $seat_rs->find( { code_from_name => $seat_name } )
              || warn("Can't find seat '$seat_name' from '$scrape_source'")
              && next;

            # Make sure that the candidate is assigned to their seat
            $candidate->add_to_candidacies( { seat => $seat } )
              unless $candidate->count_related(
                candidacies => { seat_id => $seat->id } );
        }
    }

    return 1;
}

1;
