package YourNextMP::Form::AuthLogin;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'YourNextMP::Form::Render::CompactTable';

has_field 'email' => (
    type             => 'Email',
    label            => 'Email',
    required         => 1,
    required_message => 'Please enter an email',
);

has_field 'password' => (
    type             => 'Password',
    label            => 'Password',
    required         => 1,
    required_message => "Please enter a password",
);

has_field 'login' => (
    type  => 'Submit',
    value => 'Log in'
);

no HTML::FormHandler::Moose;

1;
