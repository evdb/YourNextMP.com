package YourNextMP;

use strict;
use warnings;

use Catalyst::Runtime;    # 5.80;
use List::MoreUtils 'uniq';

# use Moose;
# use namespace::autoclean;

use Catalyst (
    '-Debug',
    'ConfigLoader',
    'Static::Simple',
    'Unicode',

    'Authentication',     # 'Authorization::Roles',
    'Session',
    'Session::State::Cookie',
    'Session::Store::DBIC',
);

use base 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'YourNextMP',

    'Plugin::Session' => {
        dbic_class => 'DB::Sessions',
        expires    => 3600,
    },

    authentication => {
        realm => {
            auto_create_user => 1,
            auto_update_user => 1,
        },
        default_realm => 'default',
        realms        => {
            default => {
                credential => {    #
                    class         => 'Password',
                    password_type => 'none',
                },
                store => {
                    class       => 'DBIx::Class',
                    user_model  => 'DB::Users',
                    role_column => 'roles',
                }
            },
            openid => {
                credential => {
                    debug => 1,          # FIXME - should not be on by default
                    class => "OpenID",

                    # extensions => [
                    #     'http://openid.net/srv/ax/1.0' => {
                    #         required => 'email',
                    #         mode     => 'fetch_request',
                    #         'type.email' =>
                    #           'http://schema.openid.net/contact/email',
                    #     },
                    # ],
                },
                store => { class => 'Null', },
            },
        }
    },

);

# Start the application
__PACKAGE__->setup();

=head2 db

    $result_set = $c->db( 'result_set_name' );

Conveniance method - the same as calling

  $c->model('DB')->resultset('result_set_name');

=cut

sub db {
    return $_[0]->model('DB')->resultset( $_[1] );
}

=head2 can_do_output

    $c->can_do_output( 'json', ... );

Tells the app that the action can produce an additional output.

=cut

sub can_do_output {
    my $c           = shift;
    my @new_outputs = @_;

    my $existing_outputs = $c->stash->{available_output_formats} || [];

    $c->stash->{available_output_formats} =
      [ uniq @new_outputs, @$existing_outputs ];

    return 1;
}

sub output_is {
    my $c      = shift;
    my $format = shift;

    my $requested = $c->req->param('output') || 'html';
    return $format eq $requested;
}

=head2 divert_to

    $c->divert_to( $uri );

Divert the user to the given URI. Will also store the current URI so that the
user can be returned here after the diversion.

=cut

sub divert_to {
    my $c   = shift;
    my $uri = shift;

    # store where we currently are
    $c->session->{post_diversion_url} = $c->req->uri;

    # redirect to the requested place
    $c->res->redirect($uri);
    $c->detach;
}

=head2 return_from_diversion

    $c->return_from_diversion( { fallback => c.uri_for('/foo/bar') } );

Sometimes the user get diverted - eg because they need to in.

This method will return them to where they wore going before the diversion.

=cut

sub return_from_diversion {
    my $c = shift;
    my $args = shift || {};

    # get the url to return to
    my $url =
         delete( $c->session->{post_diversion_url} )
      || $args->{fallback}
      || $c->uri_for('/');

    $c->res->redirect($url);

    $c->detach;
}

=head1 NAME

YourNextMP - Catalyst based application

=head1 SYNOPSIS

    script/yournextmp_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<YourNextMP::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
