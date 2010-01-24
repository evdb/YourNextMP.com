package YourNextMP::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(    #
    schema_class => 'YourNextMP::Schema::YourNextMPDB',
);

1;
