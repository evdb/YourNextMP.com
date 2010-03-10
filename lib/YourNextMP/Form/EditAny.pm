package YourNextMP::Form::EditAny;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

no HTML::FormHandler::Moose;

1;
