package YourNextMP::Schema::YourNextMPDB::Result::BadDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    "+YourNextMP::Schema::YourNextMPDB::Base::Component",
    "InflateColumn::DateTime", );

=head1 NAME

YourNextMP::Schema::YourNextMPDB::Result::BadDetail

=cut

__PACKAGE__->table("bad_details");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: SCALAR(0x9ac798)
  is_auto_increment: 1
  is_nullable: 0

=head2 candidate_id

  data_type: bigint
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0

=head2 detail

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 issue

  data_type: character varying
  default_value: undef
  is_nullable: 0
  size: 20

=head2 act_after

  data_type: timestamp without time zone
  default_value: undef
  is_nullable: 0

=head2 act_count

  data_type: integer
  default_value: undef
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        default_value     => \"nextval('bad_details_id_seq'::regclass)",
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "candidate_id",
    {
        data_type      => "bigint",
        default_value  => undef,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "detail",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
    },
    "issue",
    {
        data_type     => "character varying",
        default_value => undef,
        is_nullable   => 0,
        size          => 20,
    },
    "act_after",
    {
        data_type     => "timestamp without time zone",
        default_value => undef,
        is_nullable   => 0,
    },
    "act_count",
    { data_type => "integer", default_value => undef, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
    "bad_details_candidate_id_detail_key",
    [ "candidate_id", "detail" ],
);

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<YourNextMP::Schema::YourNextMPDB::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
    "candidate",
    "YourNextMP::Schema::YourNextMPDB::Result::Candidate",
    { id => "candidate_id" }, {},
);

# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-26 17:55:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YUEyxzbPOWEpf+3Yt4UuBg

use DateTime;

sub _store_edits { 0; }

__PACKAGE__->resultset_attributes( { order_by => ['act_after'] } );

sub new {
    my $class = shift;
    my $args  = shift;

    $args->{act_after} ||= DateTime->now;
    $args->{act_count} ||= 0;

    return $class->next::method( $args, @_ );
}

=head2 others_for_candidate

    $details = $detail->others_for_candidate(  );

Returns a rs with all the other bad_details for the candidate.

=cut

sub others_for_candidate {
    my $self = shift;

    return $self->result_source->resultset->search(
        {
            candidate_id => $self->candidate_id,
            id           => { '!=' => $self->id },
        }
    );
}

1;
