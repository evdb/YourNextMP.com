package YourNextMP::Controller::Auth;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

use Digest::MD5 qw( md5_hex );

sub login : Local {
    my ( $self, $c ) = @_;

    # FIXME - abstract this slightly
    $c->stash->{reason} = $c->session->{__diversion}{reason};

    # FIXME - add smarts to try correct login method based on parameters present

    my $reauth_user_args = undef;
    my $realm            = 'openid';

    # FIXME - Generalize for all 'offsite' realms
    my $openid_identifier    #
      = $c->req->param('openid_identifier')
      || $c->req->param('openid.identity');

    if ($openid_identifier) {

        # put this message on the stash - if login works we will be redirected
        # away
        $c->stash->{auth_error} =
            "Could not login using '$openid_identifier'..."
          . " - please check and try again.";

        if ( $c->authenticate( {}, $realm ) ) {

            # We are logged in using openid, but lets do it again so that we get
            # a proper user object
            $reauth_user_args = { openid_identifier => $c->user->url };

        }
    }

    # FIXME - temporary hack to work on a plane when no openid was available
    if ( $c->debug && $c->req->param('become_user_id') ) {
        $reauth_user_args = { id => $c->req->param('become_user_id') };
    }

    if ($reauth_user_args) {

        my $user = $c->db('User')->find_or_create($reauth_user_args)
          || "Could not find/create user after openid login";

        # re-auth using default realm
        $c->authenticate($reauth_user_args)
          || die "Error authenticating after openid login";

        $c->return_from_diversion(
            {
                fallback_return_url => $c->uri_for( '/users', $user->id )    #
            }
        );
    }
}

sub logout : Local {
    my ( $self, $c ) = @_;

    # only actually do the logout if the form was posted
    # really blow the session away so that there is no cookie
    if ( $c->req->method eq 'POST' ) {
        $c->logout;
        $c->delete_session('logout');
    }
}

sub dc_login : Local {
    my ( $self, $c ) = @_;
    my $params = $c->req->params;

    my $dc_id = delete( $params->{dc_user_id} ) || 0;
    my $sig   = delete( $params->{sig} )        || '';
    my $task  = delete( $params->{task} )       || '';

    # check that we have the user_id that we need.
    unless ( $dc_id && $task && $sig ) {
        $c->stash->{error_code} = 'missing_details';
        return;
    }

    # check that the signature is correct
    my $login_secret = $c->config->{democracy_club}{login_secret}
      || die "need 'login_secret'";
    my $expected_sig = md5_hex( $dc_id . $login_secret );
    unless ( $sig eq $expected_sig ) {
        warn "DC sig mismatch: expected '$expected_sig'"
          . " but got '$sig' for dc_id '$dc_id'";
        $c->stash->{error_code} = 'bad_sig';
        return;
    }

    # Get the user
    my $user = $c->db('User')->find_or_create( { dc_id => $dc_id } );

    # set the name if we need to
    if ( my $name = delete $params->{name} ) {
        $user->update( { name => $name } )
          unless $user->name && $user->name eq $name;
    }
    elsif ( !$user->name ) {
        $user->update( { name => "DemocracyClub User " . $user->dc_id } );
    }

    # re-auth using default realm
    $c->authenticate( { id => $user->id } )
      || die "Error authenticating after dc login";

    # now send the user where they need to go
    my $url = $c->uri_for( '/democracyclub', $task, $params );
    $c->res->redirect($url);
    return;

}

sub need_dc_user : Local {
    my ( $self, $c ) = @_;

    # pass thru
}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
