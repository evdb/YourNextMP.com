package YourNextMP::Form::SuggestionAdd;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has_field 'referer' => (    #
    type => 'Hidden',
);

has_field 'email' => (
    type  => 'Email',
    label => 'Email (optional)',
);

has_field 'type' => (
    type         => 'Select',
    label        => 'Type',
    empty_select => '--- please choose one ---',
    options      => [
        { value => 'correction', label => 'Correction' },
        { value => 'suggestion', label => 'Suggestion' },
    ],
    required => 1,
);

has_field 'suggestion' => (
    type             => 'TextArea',
    label            => 'Message',
    required         => 1,
    required_message => 'Please enter a message',
);

has_field 'submit' => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
