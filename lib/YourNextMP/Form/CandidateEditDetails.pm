package YourNextMP::Form::CandidateEditDetails;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

use YourNextMP::Schema::YourNextMPDB::Result::Candidate;
my $candidate_rs = "YourNextMP::Schema::YourNextMPDB::Result::Candidate";

my $parliament_error_message    #
  = 'Westminster contact details can not be used during the election'
  . ' - please enter alternative details';

has_field 'email' => (
    type  => 'Email',
    label => 'Email',
    apply => [
        {
            check => sub { !$candidate_rs->is_parliamentary_email( $_[0] ) },
            message => $parliament_error_message,
        }
    ],
);

has_field 'phone' => (
    type  => 'Text',
    label => 'Phone',
    apply => [
        {
            check => sub { !$candidate_rs->is_parliamentary_number( $_[0] ) },
            message => $parliament_error_message,
        }
    ],
);

has_field 'fax' => (
    type  => 'Text',
    label => 'Fax',
    apply => [
        {
            check => sub { !$candidate_rs->is_parliamentary_number( $_[0] ) },
            message => $parliament_error_message,
        }
    ],
);

has_field 'address' => (
    type  => 'TextArea',
    label => 'Postal address',
    cols  => 60,
    rows  => 4,
    apply => [
        {
            check => sub { !$candidate_rs->is_parliamentary_address( $_[0] ) },
            message => $parliament_error_message,
        }
    ],
);

has_field 'submit' => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
