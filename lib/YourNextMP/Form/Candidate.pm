package YourNextMP::Form::Candidate;

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

has_field 'email'   => ( type => 'Email',    label => 'Email', );
has_field 'phone'   => ( type => 'Text',     label => 'Phone number(s)' );
has_field 'fax'     => ( type => 'Text',     label => 'Fax number(s)' );
has_field 'address' => ( type => 'TextArea', label => 'Address' );

# Fields to add

# photo
# bio

has_field 'party' => (
    type  => 'Select',
    label => 'Political party',
);

# FIXME - some candidates stand in several seats. We should support this.
has_field 'seats' => (
    type  => 'Select',
    label => 'Standing in',
);

has_field submit => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
