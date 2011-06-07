use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use Plack::Builder;

YourNextMP->setup_engine('PSGI');
my $app = sub { YourNextMP->run(@_) };

use YourNextMP::Schema::YourNextMPDB::ResultSet::Image;

builder {

    # If request is from localhost then must be from a proxy
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1'; }
    "Plack::Middleware::ReverseProxy";

    enable "Plack::Middleware::Static",
      path => qr{^/static/},
      root => 'root/';

    my $images_root =
      YourNextMP::Schema::YourNextMPDB::ResultSet::Image->store_dir;
    enable "Plack::Middleware::Static",
      path => qr{^/images/},
      root => "$images_root";

    $app;
};
