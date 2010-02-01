package YourNextMP::Schema::YourNextMPDB::ResultSet::File;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;

use Carp;
use File::Slurp;
use LWP::UserAgent;
use Digest::MD5 'md5_hex';

my %FORMATS = (    #
    '20x20' => { height => 20, width => 20 },
    '40x40' => { height => 40, width => 40 },
);

sub create {
    my $rs   = shift;
    my $args = shift;

    # set a format if none has been set
    $args->{format} ||= 'original';

    # if this is not an original try to create it from the original
    if ( $args->{format} ne 'original' ) {

        my $specs = $FORMATS{ $args->{format} }
          || croak "format '$args->{format}' is invalid";

        # Find the original
        my $original =
          $rs->find( { md5 => $args->{md5}, format => 'original' } )
          || croak "Could not find original with md5 '$args->{md5}";

        # get an image to format
        my $image = $original->imlib_image;

        # work out which dimension to scale
        my $desired_ratio = $specs->{width} / $specs->{height};
        my $image_ratio   = $image->width / $image->height;
        my ( $width, $height ) =
          $desired_ratio >= $image_ratio
          ? ( 0, $specs->{height} )
          : ( $specs->{width}, 0 );
        my $scaled_image = $image->create_scaled_image( $width, $height );

        # get the data from the scaled image
        $scaled_image->image_set_format("png");
        my $tmp = File::Temp->new( SUFFIX => '.png' );
        $scaled_image->save($tmp);

        $args->{data}      = read_file($tmp);
        $args->{mime_type} = 'image/png';
        $args->{source}    = 'generated from original';
    }

    return $rs->next::method($args);
}

sub create_from_url {
    my $rs  = shift;
    my $url = shift;

    my $response  = LWP::UserAgent->new->get($url);
    my $mime_type = $response->header('Content-Type');

    return if $mime_type !~ m{^image/};

    return $rs->update_or_create(
        {
            md5       => md5_hex( $response->content ),
            format    => 'original',
            data      => $response->content,
            mime_type => $mime_type,
            source    => "$url",
        }
    );
}

1;
