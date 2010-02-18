package YourNextMP::Form::AddCandidate;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has_field 'name' => (
    type             => 'Text',
    label            => "Name",
    required         => 1,
    required_message => 'Please enter a name',
);

has_field 'party' => (
    type             => 'Select',
    label            => 'Political party',
    required         => 1,
    required_message => "Please select the party",
);

has_field 'seats' => (
    type             => 'Select',
    label            => 'Constituency',
    required         => 1,
    required_message => 'Please select the constituency',
);

has_field 'submit' => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
