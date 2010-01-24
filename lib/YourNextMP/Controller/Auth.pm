package YourNextMP::Controller::Auth;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

sub login : Local {
    my ( $self, $c ) = @_;

    # FIXME - add smarts to try correct login method based on parameters present

    my $reauth_user_args = undef;
    my $realm            = 'openid';

    # FIXME - Generalize for all 'offsite' realms
    my $openid_identifier    #
      = $c->req->param('openid_identifier')
      || $c->req->param('openid.identity');
    if ($openid_identifier) {
        if ( $c->authenticate( {}, $realm ) ) {

          # We are logged in using openid, but lets do it again so that we get a
          # proper user object
            $reauth_user_args = { openid_identifier => $c->user->url };

        }
        else {
            $c->stash->{auth_error} =
"Could not login using '$openid_identifier'... - please check and try again.";
        }
    }

    if ($reauth_user_args) {

        my $user = $c             #
          ->model('DB')           #
          ->resultset('Users')    #
          ->find_or_create($reauth_user_args)
          || "Could not find/create user after openid login";

        # re-auth using default realm
        $c->authenticate($reauth_user_args)
          || die "Error authenticating after openid login";

        $c->return_from_diversion(
            {
                fallback => $c->uri_for( '/users', $user->id )    #
            }
        );
    }

}

sub logout : Local {
    my ( $self, $c ) = @_;

    # only actually do the logout if the form was posted
    $c->logout if $c->req->method eq 'POST';

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
