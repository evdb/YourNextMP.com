package YourNextMP::Schema::YourNextMPDB::Base::Component;
use base qw(DBIx::Class);

use strict;
use warnings;

use DateTime;
use Class::C3;
use YourNextMP;

sub _store_edits { 1; }

sub insert {
    my $self = shift;
    my $args = shift;

    my $now = DateTime->now();
    $self->created($now);
    $self->updated($now);

    my $result = $self->next::method( $args, @_ );

    $self->add_to_edits(
        {
            source_table => $self->table,
            data         => { $self->get_columns },
            edit_type    => 'insert',
            user_id      => YourNextMP->edit_user_id,
            comment      => YourNextMP->edit_comment,
        }
    ) if $self->_store_edits;

    return $result;
}

sub update {
    my $self = shift;
    my $args = shift;

    my %dirty           = $self->get_dirty_columns();
    my $row_has_changed = scalar keys %dirty;

    $self->updated( DateTime->now() )
      if $row_has_changed;

    my $result = $self->next::method( $args, @_ );

    # store data to edits
    $self->add_to_edits(
        {
            source_table => $self->table,
            data         => { $self->get_columns },
            edit_type    => 'update',
            user_id      => YourNextMP->edit_user_id,
            comment      => YourNextMP->edit_comment,
        }
    ) if $row_has_changed && $self->_store_edits;

    return $result;
}

sub delete {
    my $self = shift;
    my $args = shift;

    $self->add_to_edits(
        {
            source_table => $self->table,
            data         => {},
            edit_type    => 'delete',
            user_id      => YourNextMP->edit_user_id,
            comment      => YourNextMP->edit_comment,
        }
    ) if $self->_store_edits;

    my $result = $self->next::method( $args, @_ );

    return $result;
}

=head2 extract_fields

    \%hash = $result->extract_fields( qw( list of fields ) );

Extracts and returns the database values for the given fields.

=cut

sub extract_fields {
    my $self   = shift;
    my @fields = @_;
    my %data   = ();

    $data{$_} = $self->get_column($_) for @fields;

    return \%data;
}

1;
