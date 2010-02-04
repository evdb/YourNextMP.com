package YourNextMP::Schema::YourNextMPDB::ResultSet::Candidate;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use utf8;

sub clean_name {
    my $class = shift;
    my $name  = shift;

    # Strip out silly additions to names (tories particularly keen on this)
    for ($name) {

        # Clean up whitespace
        s{\s+}{ }g;

        s{^Rt Hon }{};
        s{^Hon }{};
        s{^Cllr }{}i;
        s{^Sir }{}i;
        s{^Dr }{}i;

        s{ MP$}{};
        s{ MEP$}{};
        s{ MSP$}{};
        s{ Bt$}{};
        s{ TD$}{};
        s{ QC$}{};
        s{ OBE$}{};
        s{ CBE$}{};
        s{ AM$}{};

        s{^\s+}{};
        s{\s+$}{};
    }

    return $name;

}

sub name_to_code {
    my $class = shift;
    my $name  = shift;

    $name = $class->clean_name($name);

    my $code = lc $name;

    $code =~ s{'}{}g;
    $code =~ s{[^[:alpha:]]+}{_}g;

    $code =~ s{é}{e}g;
    $code =~ s{ö}{o}g;
    $code =~ s{â}{a}g;

    die "bad chars in '$code'" if $code =~ m{[^a-z_]};

    # printf "%30s -> %30s\n", $name, $code;

    return $code;
}

1;
