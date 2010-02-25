package YourNextMP::Form::UserEdit;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has_field 'name' => (
    type             => 'Text',
    label            => 'Your name',
    required         => 1,
    required_message => 'Please enter a name',
);

has_field 'email' => (
    type           => 'Email',
    label          => 'Email',
    unique         => 1,
    unique_message => 'That email address is already taken',
);

# the css_class, title, and widget attributes are for use in templates
has_field 'postcode' => (
    type     => 'Text',
    required => 0,
    title    => 'Your post code',
);

has_field submit => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
