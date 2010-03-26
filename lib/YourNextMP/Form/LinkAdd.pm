package YourNextMP::Form::LinkAdd;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'YourNextMP::Form::Render::Table';

has_field 'url' => (
    type             => '+YourNextMP::Form::Field::WebAddress',
    label            => 'URL',
    required         => 1,
    required_message => 'Please enter the web address for the link',
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Create Link'
);

no HTML::FormHandler::Moose;

1;
