package YourNextMP::Form::AuthResetPassword;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::CompactTable';

has_field 'password' => (
    type             => 'Password',
    label            => 'Password',
    required         => 1,
    required_message => "Please enter a password",
);

has_field 'password_conf' => (
    type             => 'PasswordConf',
    label            => 'Password (again)',
    password_field   => 'password',
    required         => 1,
    required_message => "Please confirm the password",
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Reset Password'
);

around 'update_model' => sub {
    my $orig = shift;
    my $form = shift;
    my $user = $form->item;

    my $values = $form->value;
    $user->password( $user->crypt_password( $values->{password} ) );
    $user->token('');
    return $user->update;
};

no HTML::FormHandler::Moose;

1;
