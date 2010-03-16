package YourNextMP::Form::CandidateEditBadDetails;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'YourNextMP::Form::CandidateEditDetails';
with 'HTML::FormHandler::Render::Simple';

has_field 'bad_detail_id' => (    #
    type => 'Hidden',
);

has_field 'submit' => (           #
    type  => 'Submit',
    value => 'Done - show me the next one!',
);

has_field 'skip' => (             #
    type      => 'Submit',
    value     => "Skip this one",
    css_class => 'discreet',
);

no HTML::FormHandler::Moose;

1;
