package YourNextMP::Controller::Files;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use HTTP::Date;

sub default : Path {
    my ( $self, $c, $md5, $format ) = @_;
    $format ||= 'original';

    my $file_rs = $c->db('File');

    my $file = $file_rs->find_or_create( { md5 => $md5, format => $format } )
      || $c->detach('/page_not_found');

    my $res  = $c->res;
    my $data = $file->data;

    use bytes;
    $res->body($data);
    $res->content_type( $file->mime_type );
    $res->content_length( length $data );

    # set the cache headers
    my $max_age     = 4 * 7 * 86400;     # 4 weeks
    my $expire_time = time + $max_age;
    $res->header( 'Cache-Control' => "max-age=$max_age" );
    $res->header( 'Expires'       => time2str($expire_time) );
    $res->header( 'Last-Modified' => time2str( $file->updated->epoch ) );

}

1;
