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
    value     => 'Skip',
    css_class => 'action_button skip_state'
);

no HTML::FormHandler::Moose;

1;
