package YourNextMP::AutoCRUD;
use base 'Catalyst';

use strict;
use warnings;

# Sillyness to mute warnings about missing hard to fullfil dep
BEGIN {
    local $SIG{__WARN__} = sub {
        warn @_ unless $_[0] =~ m{^Math::BigInt};
    };
    eval "use Crypt::DH;";
    eval "use Crypt::DH::GMP qw(-compat);";
}

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
