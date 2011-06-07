use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use YourNextMP::Schema::YourNextMPDB::ResultSet::Image;
use Plack::Builder;

YourNextMP->setup_engine('PSGI');
my $app = sub { YourNextMP->run(@_) };

builder {

    # If request is from localhost then must be from a proxy
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1'; }
    "Plack::Middleware::ReverseProxy";

    enable "Plack::Middleware::Static",
      path => qr{^/static/},
      root => 'root/';

    enable "Plack::Middleware::Deflater",
      content_type    => [ 'text/css', 'text/html', 'application/javascript' ],
      vary_user_agent => 1;

    my $images_root =
      YourNextMP::Schema::YourNextMPDB::ResultSet::Image->store_dir;
    enable "Plack::Middleware::Static",
      path => qr{^/images/},
      root => "$images_root";

    $app;
};
