package YourNextMP::Form::AuthForgotPassword;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'YourNextMP::Form::Render::CompactTable';

has_field 'email' => (
    type             => 'Email',
    label            => 'Email',
    required         => 1,
    required_message => 'Please enter your email address',
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Send password reset link',
);

no HTML::FormHandler::Moose;

1;
