package YourNextMP::Schema::YourNextMPDB;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces( result_namespace => 'Result', );

# Created by DBIx::Class::Schema::Loader v0.05000 @ 2010-02-02 11:06:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tpUAn1bdmuPHBjEYAH+Dag

__PACKAGE__->connection(    #
    "dbi:Pg:dbname=yournextmp",    #
    "",                            #
    '',
    { AutoCommit => 1, pg_enable_utf8 => 1, }
);

1;
