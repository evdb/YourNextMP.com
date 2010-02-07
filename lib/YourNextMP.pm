package YourNextMP;

use strict;
use warnings;

use Catalyst::Runtime;    # 5.80;
use List::MoreUtils 'uniq';
use Net::Amazon::S3;
use Net::Amazon::S3::Client;

# use Moose;
# use namespace::autoclean;

use Catalyst (
    'ConfigLoader',
    'Unicode',
    'Compress::Gzip',
    'Static::Simple',

    'Authentication',    # 'Authorization::Roles',
    'Session',           # FIXME - switch to SessionHP
    'Session::State::Cookie',
    'Session::Store::DBIC',
);

use base 'Catalyst';

our $VERSION = '0.01';

use YourNextMP::Schema::YourNextMPDB::ResultSet::Image;
__PACKAGE__->config(
    static => {
        dirs         => [ 'static', 'images' ],
        include_path => [
            YourNextMP::Schema::YourNextMPDB::ResultSet::Image->store_dir . '',
            YourNextMP->path_to("root"),
        ],
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

    $c->divert_to(
        $diversion_url,
        {
            return_url => $url, # defaults to current url
            reason     => 'Need to be an admin',
        }
    );

Divert the user to the given URI. Will also store the current URI so that the
user can be returned here after the diversion.

=cut

sub divert_to {
    my $c    = shift;
    my $uri  = shift;
    my $args = shift || {};

    # store args and where we currently are
    $c->session->{__diversion} = $args;
    $c->session->{__diversion}{return_url} ||= $c->req->uri;

    # redirect to the requested place
    $c->res->redirect($uri);
    $c->detach;
}

=head2 return_from_diversion

    $c->return_from_diversion( { fallback_return_url => c.uri_for('/foo/bar') } );

Sometimes the user get diverted - eg because they need to in.

This method will return them to where they wore going before the diversion.

=cut

sub return_from_diversion {
    my $c = shift;
    my $args = shift || {};

    # diversion is over - clean up the session
    my $stored_args = delete $c->session->{__diversion};

    # get the url to return to
    my $url =
         $args->{return_url}
      || $stored_args->{return_url}
      || $args->{fallback_return_url}
      || $c->uri_for('/');

    $c->res->redirect($url);
    $c->detach;
}

=head2 require_user

    $c->require_user( "Reason user is required - passed to login template" );

Some actions need a user and this method will divert to the login page if needed.

=cut

sub require_user {
    my $c      = shift;
    my $reason = shift;

    # If we have a user return
    return 1 if $c->user_exists;

    # no user - divert to login
    $c->divert_to(
        $c->uri_for('/auth/login'),    #
        { reason => $reason }
    );

}

=head2 uri_for_image

    $uri = $c->uri_for_image( $image_id, $format );

Returns the url to the image with the given id and format. Either returns a
local '/images' path or an S3 url depending on the value of 'file_store' in
config.

=cut

sub uri_for_image {
    my ( $c, $image_id, $format ) = @_;

    my $path = YourNextMP::Schema::YourNextMPDB::Result::Image    #
      ->path_to_image( $image_id, $format, 'png' );

    my $file_store = $c->config->{file_store}
      || die "need to set 'file_store' config value";

    if ( $file_store eq 'local' ) {
        return $c->uri_for( '/', $path );
    }
    elsif ( $file_store eq 's3' ) {
        return
            'http://'
          . $c->config->{aws}{public_bucket_name}
          . '.s3.amazonaws.com/'
          . $path;
    }
    else {
        die "Can't create uri for file_store '$file_store'";
    }
}

=head2 s3bucket

    $bucket = $c->s3bucket(  );

Returns a L<Net::Amazon::S3::Client::Bucket> object which is correctly set up
according to the config.

=cut

my $CACHED_S3_OBJECT        = undef;
my $CACHED_S3_CLIENT        = undef;
my $CACHED_S3_PUBLIC_BUCKET = undef;

sub s3object {
    my $c = shift;

    return $CACHED_S3_OBJECT ||=    #
      Net::Amazon::S3->new(
        aws_access_key_id     => $c->config->{aws}{aws_access_key_id},
        aws_secret_access_key => $c->config->{aws}{aws_secret_access_key},
        retry                 => 1,
      );
}

sub s3client {
    my $c = shift;

    return $CACHED_S3_CLIENT ||=    #
      Net::Amazon::S3::Client       #
      ->new( s3 => $c->s3object );
}

sub s3bucket {
    my $c = shift;

    return $CACHED_S3_PUBLIC_BUCKET ||=    #
      $c                                   #
      ->s3client                           #
      ->bucket( name => $c->config->{aws}{public_bucket_name} );
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
