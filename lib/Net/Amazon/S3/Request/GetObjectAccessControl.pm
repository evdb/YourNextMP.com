package Net::Amazon::S3::Request::GetObjectAccessControl;
use Moose;
use MooseX::StrictConstructor;
extends 'Net::Amazon::S3::Request';

has 'bucket' => ( is => 'ro', isa => 'BucketName',  required => 1 );
has 'key'    => ( is => 'ro', isa => 'Str',         required => 1 );

__PACKAGE__->meta->make_immutable;

sub http_request {
    my $self = shift;

    return Net::Amazon::S3::HTTPRequest->new(
        s3     => $self->s3,
        method => 'GET',
        path   => $self->_uri($self->key) . '?acl',
    )->http_request;
}

1;

__END__

=head1 NAME

Net::Amazon::S3::Request::GetObjectAccessControl - An internal class to get an object's access control

=head1 SYNOPSIS

  my $http_request = Net::Amazon::S3::Request::GetObjectAccessControl->new(
    s3     => $s3,
    bucket => $bucket,
    key    => $key,
  )->http_request;

=head1 DESCRIPTION

This module gets an object's access control.

=head1 METHODS

=head2 http_request

This method returns a HTTP::Request object.

