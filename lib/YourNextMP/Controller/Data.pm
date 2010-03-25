package YourNextMP::Controller::Data;
use parent 'Catalyst::Controller';

use strict;
use warnings;
use Path::Class;

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

    # redirect so that the file name is correct
    $c->res->redirect(
        $c->uri_for(
            '/data', $c->stash->{api_token},
            'file',  $file->id,
            $file->filename
        )
    );
}

sub get_file : PathPart('file') Chained('get_token') Args(2) {
    my ( $self, $c, $id, $filename ) = @_;

    $id =~ s{\D+}{}g;

    my $file = $c->db('DataFile')->find( $id || 0 )
      || $c->detach('page_not_found');

    $c->forward( 'send_file', [$file] );
}

sub send_file : Private {
    my ( $self, $c, $file ) = @_;

    # create a tmp dir to store files in based on hostname
    my $tmp_dir = dir( '/tmp', $c->req->uri->host, 'data_files' );
    $tmp_dir->mkpath;

    my $tmp_file = $tmp_dir->file( $file->filename );

    # Fetch file from s3 if missing
    unless ( -e $tmp_file ) {
        my $s3_object = $c->s3_bucket->object( key => $file->s3_key, );
        $s3_object->get_filename("$tmp_file");
    }

    if ( ref( $c->engine ) eq 'Catalyst::Engine::FastCGI' ) {

        # use X-Sendfile header and let lighttpd do the heavy lifting
        $c->res->header( "Content-Disposition" =>
              sprintf( 'attachment; filename="%s"', $file->filename ) );
        $c->res->header( 'X-Sendfile' => "$tmp_file" );
        $c->res->body('replaced by file');
    }
    else {

        # dev server - do it ourselves
        $c->serve_static_file($tmp_file);
    }

}

1;
