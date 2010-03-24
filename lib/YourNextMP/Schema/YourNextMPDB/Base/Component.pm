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

my $AS_DATA_CACHE = undef;

sub zap_as_data_cache {
    $AS_DATA_CACHE = undef;
}

sub as_data {
    my $self          = shift;
    my $args          = shift || {};
    my $public_fields = $self->public_fields;
    my %data          = ();

    # Sometimes we don't want to follow relationships as it might cause loops
    my $no_relationships = $args->{no_relationships} || 0;

    # should we zap the cache
    $self->zap_as_data_cache unless $args->{keep_cache};

    foreach my $field ( keys %$public_fields ) {

        my $spec = $public_fields->{$field} || {};

        # overide no relationships for some fields
        my $follow_relationships = 1;
        $follow_relationships = 0 if $no_relationships && $spec->{is_rel};

        # can this value be cached - if so create a cache key for it?
        my $cache_on = $spec->{cache_on} || '';
        my $cache_key = '';
        $cache_key = sprintf( '%s:%s', $field, $self->$cache_on )
          if $cache_on && $self->$cache_on;

        if ( $cache_key && exists $AS_DATA_CACHE->{$cache_key} ) {    # cached
            $data{$field} = $AS_DATA_CACHE->{$cache_key};
            next;
        }

        my $field_method = $spec->{method} || $field;

        my $val    = $self->$field_method;
        my $ref    = ref $val;
        my $output = undef;

        if ( !defined $val ) {    # nulls go straight through
            $output = undef;
        }

        elsif ( $ref =~ m{^YourNextMP::Model::DB::} ) {    # rows
            next unless $follow_relationships;
            $output                                        #
              = $val->as_data( { no_relationships => 1, keep_cache => 1 } );
        }

        elsif ( $ref =~ m{^YourNextMP::Schema::YourNextMPDB::ResultSet::} ) {
            next unless $follow_relationships;
            $output =
              $val->as_data( { no_relationships => 1, keep_cache => 1 } );
        }

        elsif ( $ref eq 'HASH' ) {    # simple hashes can be possed through
            $output = $val;
        }

        else {                        # stringify all remaining values
            $output = $val . "";
        }

        $data{$field} = $output;

        # store in cache
        $AS_DATA_CACHE->{$cache_key} = $output if $cache_key;
    }

    return \%data;
}

sub path {
    my $self = shift;
    return unless $self->can('code');
    return join '/', '', $self->table, $self->code;
}

sub _create_random_token {
    my $self   = shift;
    my $length = shift || 20;
    my @chars  = ( 'a' .. 'z', 0 .. 9 );
    my $token  = join '', map { $chars[ rand scalar @chars ] } ( 1 .. $length );
    return $token;
}

1;
