package YourNextMP::Schema::YourNextMPDB::ResultSet::Edit;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;

sub last {
    my $rs = shift;
    return $rs->search( undef, { order_by => 'edited desc' } )->first;
}

1;
