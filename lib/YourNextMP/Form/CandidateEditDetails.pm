package YourNextMP::Form::CandidateEditDetails;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has_field 'email' => (
    type  => 'Email',
    label => 'Email',
);

has_field 'phone' => (
    type  => 'Text',
    label => 'Phone',
);

has_field 'fax' => (
    type  => 'Text',
    label => 'Fax',
);

has_field 'address' => (
    type  => 'TextArea',
    label => 'Postal address',
    cols  => 60,
    rows  => 4,
);

has_field 'submit' => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
