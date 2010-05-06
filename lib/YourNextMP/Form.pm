package YourNextMP::Form;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'YourNextMP::Form::Render::Table';

has_field 'submit' => (
    type  => 'Submit',
    value => 'Save',
    order => 1000,

);

no HTML::FormHandler::Moose;

1;
