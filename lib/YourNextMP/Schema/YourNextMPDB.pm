package YourNextMP::Schema::YourNextMPDB;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-01-21 13:04:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ViIqM4K2wCh6smiHHLkcRA

__PACKAGE__->connection(    #
    "dbi:mysql:yournextmp",    #
    "root",                   #
    '',
    { AutoCommit => 1, mysql_enable_utf8 => 1, }
);

1;
