package YourNextMP::Schema::YourNextMPDB::ResultSet::Parties;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use utf8;

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

1;
