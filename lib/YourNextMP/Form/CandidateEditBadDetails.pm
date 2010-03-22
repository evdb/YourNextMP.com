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
    type      => 'Submit',
    value     => 'Save',
    css_class => 'action_button save_state'
);

has_field 'skip' => (             #
    type      => 'Submit',
    value     => "I can't find it! skip them.",
    css_class => 'action_button skip_state'
);

no HTML::FormHandler::Moose;

1;
