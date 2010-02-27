package YourNextMP::Form::CandidateEditBadDetails;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'YourNextMP::Form::CandidateEditDetails';

has_field 'bad_detail_id' => (    #
    type => 'Hidden',
);

no HTML::FormHandler::Moose;

1;
