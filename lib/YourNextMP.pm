package YourNextMP;

use strict;
use warnings;

use Catalyst::Runtime;    # 5.80;
use Carp;
use List::MoreUtils 'uniq';
use Net::Amazon::S3;
use Net::Amazon::S3::Client;

# use Moose;
# use namespace::autoclean;

use Catalyst (
    'ConfigLoader',
    'Cache',
    'Unicode',
    'Compress::Gzip',
    'Static::Simple',

    'Authentication',
    'Authorization::Roles',
    'SessionHP::State::Cookie',
    'Session::Store::DBIC',
    'SessionHP',
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

=head2 require_user, require_dc_user, require_admin_user

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

sub require_admin_user {
    my $c      = shift;
    my $reason = shift;

    # If we have a user and they are in the admin role
    return 1 if $c->user_is_admin;

    # no user - divert to login
    $c->divert_to(
        $c->uri_for('/auth/login'),    #
        { reason => $reason }
    );
}

sub require_dc_user {
    my $c      = shift;
    my $reason = shift;

    # If we have a user return
    return 1
      if $c->user_exists
          && $c->user->dc_id;

    # no user - explain the problem
    $c->res->redirect( $c->uri_for('/auth/need_dc_user') );

}

=head2 user_is_admin

    $bool = $c->user_is_admin(  );

Returns true if there is a user and they are an admin user.

=cut

sub user_is_admin {
    my $c = shift;

    return 1
      if $c->user_exists
          && $c->check_user_roles('admin');

    return;
}

=head2 uri_for_image

    $uri = $c->uri_for_image( $image_id, $format );

Returns the url to the image with the given id and format. Either returns a
local '/images' path or an S3 url depending on the value of 'file_store' in
config.

If the image_id is false then the standard 'no-photo-xxx.png' is used.

=cut

sub uri_for_image {
    my ( $c, $image_id, $format ) = @_;

    return $c->uri_for_no_image($format) unless $image_id;

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

=head2 uri_for_no_image

    $c->uri_for_no_image( $format );

Returns the uri to the appropriate 'no-photo-xxx.png' image.
=cut

sub uri_for_no_image {
    my $c      = shift;
    my $format = shift;

    return $c->uri_for("/static/no-photo-$format.png");
}

=head2 s3_bucket

    $bucket = $c->s3_bucket(  );

Returns a L<Net::Amazon::S3::Client::Bucket> object which is correctly set up
according to the config.

=cut

my $CACHED_S3_OBJECT       = undef;
my $CACHED_S3_CLIENT       = undef;
my %CACHED_S3_BUCKET_CACHE = ();

sub s3_object {
    my $c = shift;

    return $CACHED_S3_OBJECT ||=    #
      Net::Amazon::S3->new(
        aws_access_key_id     => $c->config->{aws}{aws_access_key_id},
        aws_secret_access_key => $c->config->{aws}{aws_secret_access_key},
        retry                 => 1,
      );
}

sub s3_client {
    my $c = shift;

    return $CACHED_S3_CLIENT ||=    #
      Net::Amazon::S3::Client       #
      ->new( s3 => $c->s3_object );
}

sub s3_bucket {
    my $c = shift;

    my $bucket_name = shift || $c->config->{aws}{public_bucket_name};

    return $CACHED_S3_BUCKET_CACHE{$bucket_name} ||=    #
      $c                                                #
      ->s3_client                                       #
      ->bucket( name => $bucket_name );
}

my $EDIT_USER    = undef;
my $EDIT_COMMENT = undef;

sub edit_user {
    my $class = shift;
    $EDIT_USER = shift if @_;
    return $EDIT_USER;
}

sub edit_user_id {
    return $EDIT_USER ? $EDIT_USER->id : undef;
}

sub edit_comment {
    my $class = shift;
    $EDIT_COMMENT = shift if @_;
    return $EDIT_COMMENT;
}

sub clear_edit_details {
    $EDIT_COMMENT = undef;
    $EDIT_USER    = undef;
}

sub finalize {
    my $c      = shift;
    my $result = $c->next::method(@_);
    $c->clear_edit_details;
    return $result;
}

=head2 smart_cache

    $value = $c->smart_cache(
        {
            key  => 'foo_bar',
            code => sub {
                return { this => 'is cached' };
            },
            expires => 3600,    # how long to cache in seconds
        }
    );

Checks for a valid entry in the cache and returns it. If there is no valid entry then the 'code' is executed and the returned value is cached and returned.

If the user is logged in the code is always executed and the result cached. This means that logged-in users never see cached values and update the cached values for others. This is a cheap form of cache invalidation as after edits the user is normally redirected back to the overview page of whatever they edited.

By default C<expires> is set to one hour.

=cut

sub smart_cache {
    my $c    = shift;
    my $args = shift;

    # Extract values from args and sanity check
    my $key     = $args->{key}     || croak "Need a key to cache on";
    my $code    = $args->{code}    || croak "Need code in case of cache miss";
    my $expires = $args->{expires} || 3600;
    my $have_user = $c->user_exists;

    # get value from cache
    my $val = $have_user         # if user is logged in...
      ? undef                    # ... don't use cache
      : $c->cache->get($key);    # ... only for anonymous users

    # do we have a value from the cache?
    if ( defined $val ) {
        $c->log->debug("cache hit for '$key'");
        $c->stash->{cache_info}{hits}++;
    }
    else {
        $val = $c->_set_cache( $key => $code, $expires );
    }

    return $val;

}

sub _set_cache {
    my ( $c, $key, $code, $expires ) = @_;

    use Time::HiRes qw(time);
    my $start_time = time;

    # execute the code to generate the value
    my $value = $code->();

    # store value in the cache (if needed)
    $c->cache->set( $key => $value, $expires ) if defined $value;

    my $stop_time   = time;
    my $time_taken  = $stop_time - $start_time;
    my $req_per_sec = 1 / $time_taken;

    $c->log->debug(
        sprintf(
            "cache miss for '%s' ( %0.6fs - %0.3f/s )",
            $key, $time_taken, $req_per_sec
        )
    );

    # and return
    return $value;
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
