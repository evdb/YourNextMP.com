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
    my $args = shift;

    foreach my $key ( keys %$args ) {
        my $value = $args->{$key};

        my @values = split /\s+/, $value;

        $rs = $rs->search(    #
            {
                $key =>
                  { ilike => [ '-and', map { lc( '%' . $_ . '%' ) } @values ] }
            }
        );
    }

    return $rs;
}

sub extract_rows {
    my $rs      = shift;
    my $args    = shift;
    my @results = ();

    while ( my $row = $rs->next ) {

        my $result = {};

        foreach my $key ( keys %$args ) {
            my $value     = $args->{$key};
            my $value_ref = ref $value;

            warn "KEY: $key";

            $result->{$key} =
                $value_ref eq ''     ? $row->get_column($key)
              : $value_ref eq 'CODE' ? $value->($row)
              :   die "Can't process $key - bad ref $value_ref";
        }

        push @results, $result;
    }

    return \@results;
}

1;
