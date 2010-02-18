package YourNextMP::Controller::Parties;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

sub result_base : PathPart('parties') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Party';
}

1;
