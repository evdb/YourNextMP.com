package YourNextMP::Form::CandidateEditPersonal;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

use HTML::FormHandler::Field;

has '+field_traits' => (    #
    default => sub { ['YourNextMP::Form::TraitFor::Hint']; },
);

has_field 'gender' => (
    type    => 'Select',
    label   => 'Gender',
    options => [
        { label => 'Male',   value => 'male' },
        { label => 'Female', value => 'female' }
    ],
    empty_select => '--- please choose a gender ---',
);

has_field 'dob' => (
    type  => '+YourNextMP::Form::Field::YearOrDOB',
    label => 'Date or year of birth',
    hint  => 'dd/mm/yyyy or yyyy',
);

has_field 'birthplace' => (
    type  => 'Text',
    label => 'Place of birth',
);

has_field 'school' => (
    type  => 'Text',
    label => 'School',
);

has_field 'university' => (
    type  => 'Text',
    label => 'University',
    hint  => "Uni A; Uni B",
);

has_field 'positions' => (
    type  => 'TextArea',
    label => 'Positions held',
    apply => [
        {
            transform => sub {
                my $positions = shift;
                $positions =~ s{\s*\n\s*}{\n}g;
                $positions;
              }
        }
    ],
    hint => 'one per line: "Acme Inc, Director, 1997 to 2004"',
);

has_field 'submit' => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
