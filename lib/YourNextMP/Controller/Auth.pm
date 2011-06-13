package YourNextMP::Controller::Auth;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

use Digest::MD5 qw( md5_hex );

use YourNextMP::Form::AuthLogin;
use YourNextMP::Form::AuthCreateAccount;
use YourNextMP::Form::AuthForgotPassword;
use YourNextMP::Form::AuthResetPassword;

sub login : Local {
    my ( $self, $c ) = @_;

    # FIXME - abstract this slightly
    $c->stash->{reason} = $c->session->{__diversion}{reason};

    # set up and stash the forms
    my $user = $c->db('User')->new_result( {} );
    my $create_form = YourNextMP::Form::AuthCreateAccount->new( item => $user );
    my $login_form = YourNextMP::Form::AuthLogin->new();
    $c->stash->{login_form}          = $login_form;
    $c->stash->{create_account_form} = $create_form;

    # If not post then there is no farm submitted
    return unless $c->req->method eq 'POST';

    # choose which form we should process
    if ( $c->req->param('create_account') ) {

        $create_form->process( params => $c->req->params ) || return;
    }
    else {
        $login_form->process( params => $c->req->params ) || return;

        # try to load the user and check the password
        $user =
          $c->db('User')
          ->find( { email => $login_form->field('email')->value } );

        # check that the user exisist
        if ( !$user ) {
            push @{ $login_form->field('email')->errors },
              "There is no account for this email address";
            return;
        }

        # check that the password is correct
        my $crypt =
          $user->crypt_password( $login_form->field('password')->value );
        if ( $user->password ne $crypt ) {
            push @{ $login_form->field('password')->errors },
              "This password is not correct";
            return;
        }

    }

    $c->authenticate( { email => $user->email } )
      || die "Error authenticating after email login or create";

    $c->return_from_diversion(
        {
            fallback_return_url => $c->uri_for( '/users', $user->id )    #
        }
    );
}

sub forgot_password : Local {
    my ( $self, $c ) = @_;

    my $form = YourNextMP::Form::AuthForgotPassword->new();
    $c->stash->{form} = $form;

    $form->process( params => $c->req->params ) || return;

    my $email = $form->field('email')->value;

    my $user = $c->db('User')->find( { email => $email } );
    if ( !$user ) {
        push @{ $form->field('email')->errors },
          "There is no account for this email address";
        return;
    }

    my $token = $user->reset_random_token;
    my $reset_url = $c->uri_for( '/auth/reset_password', $user->id, $token );
    $c->send_email(
        {
            to      => $user->email,
            subject => 'YourNextMP password reset',
            body    => "Hello,

Please visit this link to reset your password:

  $reset_url

Any problems let us know by replying to this email.

Yours,
  The YourNextMP Team.

",
        }
    );

    $c->stash->{email_sent} = 1;
}

sub reset_password : Local {
    my ( $self, $c, $user_id, $user_token ) = @_;

    # get the user
    $user_id =~ s{\D}{}g;
    my $user = $c->db('User')->find( $user_id || 0 );

    # no user or token wrong - 404
    $c->detach('/page_not_found')
      unless $user
          && $user_token
          && $user->token eq $user_token;

    my $form = YourNextMP::Form::AuthResetPassword->new( item => $user );
    $c->stash->{form} = $form;
    $form->process( params => $c->req->params ) || return;

    # password reset - auth the user and send them home
    $c->authenticate( { id => $user->id } )
      || die "Error authenticating after password reset";

    $c->return_from_diversion(
        {
            fallback_return_url => $c->uri_for( '/users', $user->id )    #
        }
    );

}

sub login_openid : Local {
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
    my $url = $c->uri_for( '/game', $task, $params );
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
