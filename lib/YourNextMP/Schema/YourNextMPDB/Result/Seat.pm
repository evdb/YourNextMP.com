package YourNextMP::Schema::YourNextMPDB::Result::Seat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::Seat

=cut

__PACKAGE__->table("seats");

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

=head2 nomination_url

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 nominated_count

  data_type: integer
  default_value: undef
  is_nullable: 1

=head2 nominations_entered

  data_type: boolean
  default_value: undef
  is_nullable: 1

=head2 votes_recorded

  data_type: boolean
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
    "nomination_url",
    { data_type => "text", default_value => undef, is_nullable => 1 },
    "nominated_count",
    { data_type => "integer", default_value => undef, is_nullable => 1 },
    "nominations_entered",
    { data_type => "boolean", default_value => undef, is_nullable => 1 },
    "votes_recorded",
    { data_type => "boolean", default_value => undef, is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "seats_code_key", ["code"] );
__PACKAGE__->add_unique_constraint( "seats_name_key", ["name"] );

=head1 RELATIONS

=head2 candidacies

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidacy>

=cut

__PACKAGE__->has_many(
    "candidacies",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidacy",
    { "foreign.seat_id" => "self.id" },
);

=head2 users

Type: has_many

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::User>

=cut

__PACKAGE__->has_many(
    "users",
    "YourNextMP::Schema::YourNextMPDB::Result::User",
    { "foreign.seat_id" => "self.id" },
);

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-09 23:00:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ATxwwR4ay5dZAk7GuL+8tw

__PACKAGE__->resultset_attributes( { order_by => ['code'] } );

sub public_fields {
    return {
        code       => {},
        updated    => {},
        path       => {},
        name       => {},
        candidates => {
            method => 'standing_candidates',
            is_rel => 1
        },
    };
}

__PACKAGE__->has_many(
    "link_relations",
    "YourNextMP::Schema::YourNextMPDB::Result::LinkRelation",
    { "foreign.foreign_id" => "self.id" },
);

__PACKAGE__->many_to_many( links => link_relations => 'link' );

__PACKAGE__->many_to_many( candidates => candidacies => 'candidate' );

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

sub standing_candidates    { return $_[0]->candidates->standing; }
sub standing_candidates_rs { return scalar $_[0]->candidates->standing; }

=head2 winner

    $winner = $seat->winner(  );

Returns the candidate that won the seat, or undef if there is no winner (no
votes or draw).

=cut

sub winner {
    my $self = shift;

    return unless $self->votes_recorded;

    return $self->candidates->standing->search( is_winner => 1 )->first;
}

=head2 total_votes

    $total_votes = $seat->total_votes(  );

Returns the number of votes cast - or zero if none cast.

=cut

sub total_votes {
    my $self = shift;
    return 0 unless $self->votes_recorded;

    my $votes = 0;
    $votes += $_ for map { $_->votes } $self->candidates->standing->all;

    return $votes;
}

1;
