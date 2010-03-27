package YourNextMP::Schema::YourNextMPDB::ResultSet::Party;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use utf8;

sub clean_name {
    my $class = shift;
    my $name  = shift;

    for ($name) {

        # Clean up whitespace
        s{\s+}{ }g;

        # remove trailing '[The]'
        s{ \s* \[The\] \z }{}xmsi;

        s{^\s+}{};
        s{\s+$}{};
    }

    return $name;

}

sub name_to_code {
    my $class = shift;
    my $name  = shift;

    my $code = lc $name;
    $code =~ s{\&}{and}g;
    $code =~ s{\[the\]}{}g;
    $code =~ s{'}{}g;
    $code =~ s{á}{a}g;
    $code =~ s{é}{e}g;
    $code =~ s{\W+}{_}g;
    $code =~ s{ \A _+ }{}x;
    $code =~ s{ _+ \z }{}x;

    # We know it is a party so no need for '_party' and the end of the code
    $code =~ s{_party$}{};

    die "bad chars in '$code'" if $code =~ m{[^a-z0-9_]};

    return $code;
}

sub parties_with_candidates_as_arrayref {
    my $self = shift;

    my $rs = $self->search(
        { 'candidates.status' => ['standing'], },    #
        {
            join   => 'candidates',
            select => [
                'me.code',                           #
                'me.name',                           #
                'me.image_id',
                { count => 'candidates.id' }
            ],
            as       => [qw( code name image_id candidate_count )],
            group_by => [ 'me.code', 'me.name', 'me.image_id' ],

            order_by => 'count desc, me.code',
        }
    );

    return [
        map {
            { $_->get_columns }
          } $rs->all
    ];
}

1;
