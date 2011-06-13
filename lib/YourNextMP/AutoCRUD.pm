package YourNextMP::AutoCRUD;
use base 'Catalyst';

use strict;
use warnings;

use Catalyst::Runtime;    # 5.80;
use Catalyst ( 'Unicode', 'AutoCRUD', );

use YourNextMP;

our $VERSION = '0.01';

# Start the application
__PACKAGE__->config(
    {
        'name'                  => 'YourNextMP::AutoCrud',
        'Model::AutoCRUD::DBIC' => {
            schema_class => 'YourNextMP::Schema::YourNextMPDB',
            connect_info => YourNextMP->config->{'Model::DB'}{connect_info},
        },
    }
);

__PACKAGE__->setup();

1;
