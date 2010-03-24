package YourNextMP::Schema::YourNextMPDB::ResultSet::DataFile;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use Carp;

sub all_latest {
    my $rs = shift;

    my @types = map { $_->type } $rs->search(
        undef,
        {
            select   => ['type'],
            distinct => 1,
        }
    )->all;

    my @ids = map { $rs->latest($_)->id } @types;

    return $rs->search( { id => \@ids }, { order_by => 'name' } );
}

sub latest {
    my $rs = shift;
    my $type = shift || croak "Must specify a 'type' for latest";

    return $rs->search(
        { type => $type },
        {
            order_by => 'created desc',
            rows     => 1
        }
    )->first;
}

1;
