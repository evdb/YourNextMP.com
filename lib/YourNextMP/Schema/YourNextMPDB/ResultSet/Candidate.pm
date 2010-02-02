package YourNextMP::Schema::YourNextMPDB::ResultSet::Candidate;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use utf8;

sub name_to_code {
    my $class = shift;
    my $name  = shift;

    my $code = lc $name;

    $code =~ s{'}{}g;
    $code =~ s{[^[:alpha:]]+}{_}g;

    # Strip out silly additions to names (tories particularly keen on this)
    $code =~ s{^rt_hon_}{};
    $code =~ s{^hon_}{};
    $code =~ s{^cllr_}{};
    $code =~ s{^sir_}{};
    $code =~ s{^dr_}{};

    $code =~ s{_mp$}{};
    $code =~ s{_mep$}{};
    $code =~ s{_msp$}{};
    $code =~ s{_bt$}{};
    $code =~ s{_td$}{};
    $code =~ s{_qc$}{};
    $code =~ s{_obe$}{};
    $code =~ s{_cbe$}{};
    $code =~ s{_am$}{};

    $code =~ s{é}{e}g;
    $code =~ s{ö}{o}g;
    $code =~ s{â}{a}g;

    die "bad chars in '$code'" if $code =~ m{[^a-z_]};

    # printf "%30s -> %30s\n", $name, $code;

    return $code;
}

1;
