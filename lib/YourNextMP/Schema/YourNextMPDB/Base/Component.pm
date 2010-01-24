package YourNextMP::Schema::YourNextMPDB::Base::Component;
use base qw(DBIx::Class);

use strict;
use warnings;

use DateTime;
use Class::C3;

sub insert {
    my $self = shift;

    my $now = DateTime->now();
    $self->created($now);
    $self->updated($now);

    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->updated( DateTime->now() );

    return $self->next::method(@_);
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
