package YourNextMP::Form::SupporterAdd;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has_field 'name' => (
    type             => 'Text',
    label            => "Organization Name",
    required         => 1,
    required_message => 'Please enter a name',
);

has_field 'website' => (
    type  => 'Text',
    label => "Website URL",
);

has_field 'logo_url' => (
    type  => 'Text',
    label => "Logo URL",
);

has_field 'summary' => (
    type  => 'TextArea',
    label => "Summary",
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Save'
);

no HTML::FormHandler::Moose;

1;
