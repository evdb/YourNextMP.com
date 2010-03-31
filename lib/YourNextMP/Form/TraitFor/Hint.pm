package YourNextMP::Form::TraitFor::Hint;

use strict;
use warnings;

use Moose::Role;

has 'hint' => ( isa => 'Str', is => 'rw' );

1;
