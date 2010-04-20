package YourNextMP::Form::AddNominationURL;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has '+field_traits' => (    #
    default => sub { ['YourNextMP::Form::TraitFor::Hint']; },
);

has_field 'nomination_url' => (
    type     => '+YourNextMP::Form::Field::WebAddress',
    label    => 'URL to nominations',
    required => 1,
    required_message =>
      'Please enter the web address for the page with the nominations',
    hint => 'Please find a web page that has the nominations',
);

has_field 'nominated_count' => (
    type             => 'Integer',
    label            => 'number of nominated candidates',
    required         => 1,
    required_message => 'Please enter the number of candidates.',
    hint => 'Please count all the candidates and put the total here.'
      . ' This lets us check that we have an entry for all the candidates.',
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Save'
);

no HTML::FormHandler::Moose;

1;
