package Catalyst::Plugin::SessionHP::State::Cookie;
use base qw/Catalyst::Plugin::SessionHP::State Class::Accessor::Fast/;

use strict;
use warnings;

use MRO::Compat;
use Catalyst::Utils ();

our $VERSION = "0.10";

BEGIN { __PACKAGE__->mk_accessors(qw/_deleted_session_id/) }

sub setup_session {
    my $c = shift;

    $c->maybe::next::method(@_);

    $c->_session_plugin_config->{cookie_name} ||=
      Catalyst::Utils::appprefix($c) . '_session';

}

sub _session_cookie_name {
    my $c = shift;
    return $c->_session_plugin_config->{cookie_name};
}

sub finalize_session {
    my $c = shift;

    # we want to run after the other finalizing has been done
    $c->maybe::next::method(@_);

    # If there is no session_id then we should not do anything
    return unless $c->_session_id;

    # create the cookie
    my $cookie = { value => $c->_session_id, };

    # set the expriation time
    # get the cookie expiry time and add a little buffer for testing
    unless ( $c->session->{__session_limit_to_this_visit} ) {
        $cookie->{expires} = $c->_session_expiry_time + 60;
    }

    $cookie->{secure} = 1 if $c->_session_plugin_config->{cookie_secure};

    # add the cookie to the headers
    $c->response->cookies->{ $c->_session_cookie_name } = $cookie;

    # Also ensure that at the least the cookie is not cached. Other caching is
    # upto the app to implement. Don't apply to secure connections as it leads
    # to a bug where IE will not download files.
    # (http://support.microsoft.com/kb/812935/en-us)
    $c->response->header( 'Cache-control' => 'no-cache="set-cookie"' )
      unless $c->req->secure;
}

sub get_sesson_id_from_state {
    my $c = shift;

    # get _request_ cookie
    my $cookie = $c->request->cookies->{ $c->_session_cookie_name };

    if ($cookie) {
        my $sid = $cookie->value;
        $c->log->debug(qq/Found sessionid "$sid" in cookie/) if $c->debug;
        return $sid if $sid;
    }

    # If we could not find the id pass on to the next state
    $c->maybe::next::method(@_);
}

sub delete_session {
    my ( $c, $msg ) = @_;

    # create the cookie
    my $cookie = {
        value   => '',
        expires => 0,
    };
    $cookie->{secure} = 1 if $c->_session_plugin_config->{cookie_secure};

    # add the cookie to the headers
    $c->response->cookies->{ $c->_session_cookie_name } = $cookie;

    $c->maybe::next::method($msg);
}

1;
