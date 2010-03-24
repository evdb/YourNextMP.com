package YourNextMP::Controller::Data;
use parent 'Catalyst::Controller';

use strict;
use warnings;

sub result_base : PathPart('data') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;
}

sub get_token : PathPart('') Chained('result_base') CaptureArgs(1) {
    my ( $self, $c, $api_token ) = @_;

    # get the supporter or 404
    my $supporter = $c->db('Supporter')->find( { token => $api_token } )
      || $c->detach('/page_not_found');
    $c->stash->{supporter} = $supporter;
    $c->stash->{api_token} = $api_token;
}

sub list_downloads : PathPart('') Chained('get_token') Args(0) {
    my ( $self, $c ) = @_;

    # get the latest datafiles created.
    $c->stash->{latest_data_files} = $c->db('DataFile')->all_latest;

    $c->stash->{recent_data_files} =
      $c->db('DataFile')
      ->search( {}, { rows => 30, order_by => 'created desc' } );
}

sub latest : PathPart('latest') Chained('get_token') Args(1) {
    my ( $self, $c, $type ) = @_;

    my $file = $c->db('DataFile')->latest( $type || '-' )
      || $c->detach('page_not_found');

    $c->forward( 'redirect_to_file', [$file] );
}

sub file : PathPart('file') Chained('get_token') Args(1) {
    my ( $self, $c, $id ) = @_;

    $id =~ s{\D+}{}g;

    my $file = $c->db('DataFile')->find( $id || 0 )
      || $c->detach('page_not_found');

    $c->forward( 'redirect_to_file', [$file] );
}

sub redirect_to_file : Private {
    my ( $self, $c, $file ) = @_;

    my $five_minutes_hence =
      DateTime->now + DateTime::Duration->new( minutes => 5 );

    my $s3_object = $c->s3_bucket->object(
        key     => $file->s3_key,
        expires => $five_minutes_hence
    );

    my $uri = $s3_object->query_string_authentication_uri();

    $c->res->redirect($uri);
}

1;
