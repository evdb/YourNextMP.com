package YourNextMP::Form::AuthCreateAccount;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::CompactTable';

has_field 'name' => (
    type             => 'Text',
    label            => 'Name',
    required         => 1,
    required_message => "Please enter your name",
);

has '+unique_messages' => (
    default => sub {
        { users_email_key =>
              'There is already an account for this email address' };
    }
);

has_field 'email' => (
    type             => 'Email',
    label            => 'Email',
    required         => 1,
    required_message => 'Please enter your email address',
);

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

has_field 'create_account' => (
    type  => 'Submit',
    value => 'Create Account'
);

around 'update_model' => sub {
    my $orig = shift;
    my $form = shift;
    my $user = $form->item;

    my $values = $form->value;

    $user->name( $values->{name} );
    $user->email( $values->{email} );
    $user->password( $user->crypt_password( $values->{password} ) );

    return $user->insert;
};

no HTML::FormHandler::Moose;

1;
