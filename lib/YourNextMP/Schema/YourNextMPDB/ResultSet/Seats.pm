package YourNextMP::Schema::YourNextMPDB::ResultSet::Seats;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;
use JSON;
use Geo::Postcode;
use Encode;
use utf8;

sub name_to_code {
    my $class = shift;
    my $name  = shift;

    my $code = lc $name;
    $code =~ s{\&}{and}g;
    $code =~ s{[^[:alpha:]]+}{_}g;
    $code =~ s{ô}{o}g;

    die "bad chars in '$code'" if $code =~ m{[^a-z_]};

    return $code;
}

sub search_postcode {
    my $rs             = shift;
    my $dirty_postcode = shift;

    my $postcode = Geo::Postcode->valid($dirty_postcode);
    return unless $postcode;

    my $twfy = YourNextMP->model('TheyWorkForYou');
    my $results =
      $twfy->query( getConstituency => { postcode => $postcode, future => 1 } );

    my $cons_name = $results->{name} || '';

    return $rs->search(    #
        { name     => $cons_name },
        { order_by => 'name' }
    );
}

1;
