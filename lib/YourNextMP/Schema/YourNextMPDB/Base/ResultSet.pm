package YourNextMP::Schema::YourNextMPDB::Base::ResultSet;
use base 'DBIx::Class::ResultSet';

use strict;
use warnings;

sub find {
    my $rs   = shift;
    my $args = shift;

    if ( ref $args ) {
        if ( my $name = delete $args->{code_from_name} ) {
            $args->{code} = $rs->name_to_code($name);
        }
    }

    $rs->next::method($args);
}

sub fuzzy_search {
    my $rs   = shift;
    my $args = shift || {};
    my $opts = shift || {};

    my $combiner =
      $opts->{combiner}
      ? "-$opts->{combiner}"
      : '-and';

    foreach my $key ( keys %$args ) {
        my $value = $args->{$key};

        my @values = split /\s+/, $value;

        $rs = $rs->search(    #
            {
                $key => {
                    ilike => [ $combiner, map { lc( '%' . $_ . '%' ) } @values ]
                }
            }
        );
    }

    return $rs;
}

sub as_data {
    my $self = shift;
    my $args = shift || {};
    my @rows = ();

    my $should_cache_be_zapped = $args->{keep_cache} ? 0 : 1;

    while ( my $r = $self->next ) {

        # zap the cache on the first item if needed
        if ($should_cache_be_zapped) {
            $r->zap_as_data_cache;
            $should_cache_be_zapped = 0;
        }

        push @rows, $r->as_data( { %$args, keep_cache => 1 } );
    }

    return \@rows;
}

1;
