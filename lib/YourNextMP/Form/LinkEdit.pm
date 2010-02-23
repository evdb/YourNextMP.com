package YourNextMP::Form::LinkEdit;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

has_field 'title' => (
    label            => 'Title',
    type             => 'Text',
    required         => 1,
    required_message => 'Please enter a title',
);

has_field 'link_type' => (
    label    => 'Type of link',
    type     => 'Select',
    required => 1,
    options  => [
        { value => 'info', label => 'Information' },
        { value => 'news', label => 'News from an unbiased source' },
        {
            value => 'opinion',
            label => 'Opinion - blogs, editorials, commentary etc'
        },
    ],
);

has_field 'published' => (
    label  => 'Date published',
    type   => 'Date',
    format => "%d/%m/%Y",
);

has_field 'summary' => (
    label    => 'Summary text',
    type     => 'TextArea',
    required => 1,
    required_message =>
      'Please enter some text to summarise the contents of the page',
);

has_field submit => ( type => 'Submit' );

no HTML::FormHandler::Moose;

1;
