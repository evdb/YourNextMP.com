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
    $self->created($now) if $self->result_source->has_column('created');
    $self->updated($now) if $self->result_source->has_column('updated');

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

    $self->updated( DateTime->now )
      if $row_has_changed    #
          && $self->result_source->has_column('updated');

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

=head2 as_data

    $data = $row->as_data(  );

Returns the data for this row as data

=cut

sub as_data {
    my $self          = shift;
    my $args          = shift || {};
    my @public_fields = $self->public_fields;
    my %data          = ();

    # Sometimes we don't want to follow relationships as it might cause loops
    my $no_relationships = $args->{no_relationships} || 0;

    foreach my $field (@public_fields) {
        my $val    = $self->$field;
        my $output = undef;
        my $ref    = ref $val;

        if ( !defined $val ) {    # nulls go straight through

            $output = undef;
        }

        elsif ( $ref =~ m{^YourNextMP::Model::DB::} ) {    # rows
            next if $no_relationships;
            $output = $val->as_data( { no_relationships => 1 } );
        }

        elsif ( $ref =~ m{^YourNextMP::Schema::YourNextMPDB::ResultSet::} ) {
            next if $no_relationships;
            $output = $val->as_data( { no_relationships => 1 } );
        }

        else {    # stringify all remaining values
            $output = $val . "";
        }

        $data{$field} = $output;
    }

    return \%data;
}

sub path {
    my $self = shift;
    return join '/', '', $self->table, $self->code;
}

1;
