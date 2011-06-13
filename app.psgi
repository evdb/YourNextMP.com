use strict;
use warnings;

use lib 'lib';

use YourNextMP;
use YourNextMP::AutoCRUD;

use YourNextMP::Schema::YourNextMPDB::ResultSet::Image;
use Plack::Builder;

YourNextMP->setup_engine('PSGI');
my $ynmp_app = sub { YourNextMP->run(@_) };

YourNextMP::AutoCRUD->setup_engine('PSGI');
my $autocrud_app = sub { YourNextMP::AutoCRUD->run(@_) };

# Set up the auth
my $user_and_pass = YourNextMP->config->{'auth_basic_user_pass'};
my $authenticator = sub {
    my $username = shift;
    my $password = shift;
    my ( $u_wanted, $p_wanted ) = split /:/, $user_and_pass, 2;
    return $username eq $u_wanted && $password eq $p_wanted;
};

builder {

    mount '/extra' => builder {
        
        enable_if { $user_and_pass } "Plack::Middleware::Auth::Basic",
          realm         => YourNextMP->config->{'auth_basic_realm'},
          authenticator => $authenticator;

          $autocrud_app;
    };

    mount '/' => builder {

        enable_if { $user_and_pass } "Plack::Middleware::Auth::Basic",
          realm         => YourNextMP->config->{'auth_basic_realm'},
          authenticator => $authenticator;

        enable "Plack::Middleware::Deflater",
          content_type => [ 'text/css', 'text/html', 'application/javascript' ],
          vary_user_agent => 1;

        # enable 'Plack::Middleware::Debug';

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

        $ynmp_app;
    };
};
