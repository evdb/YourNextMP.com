package YourNextMP::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub auto : Private {
    my ( $self, $c ) = @_;

    $c->require_admin_user("Log in as an admin user to access admin section");

    return 1;
}

sub index : Path('') {
    my ( $self, $c ) = @_;

    # passthrough
}

1;
