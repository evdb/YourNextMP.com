package YourNextMP::Schema::YourNextMPDB::ResultSet::Image;
use base 'YourNextMP::Schema::YourNextMPDB::Base::ResultSet';

use strict;
use warnings;

use Carp;
use Path::Class;
use File::HomeDir;
use Image::Imlib2;
use File::Temp;
use App::Cache;
use LWP::UserAgent;
use File::Copy;

my %FORMATS = (    #
    'small'  => { height => 40,  width => 40,  suffix => 'png', },
    'medium' => { height => 100, width => 100, suffix => 'png', },
    'large'  => { height => 250, width => 250, suffix => 'png', },
);

my %MIME_TO_SUFFIX = (
    'image/jpeg' => 'jpg',
    'image/jpg'  => 'jpg',
    'image/gif'  => 'gif',
    'image/png'  => 'png'
);

my %SUFFIX_TO_MIME = reverse %MIME_TO_SUFFIX;

my $STORE_DIR = dir( File::HomeDir->my_home )->subdir('yournextmp');
$STORE_DIR->mkpath;
sub store_dir { $STORE_DIR; }

sub create {
    my $rs   = shift;
    my $args = shift;

    # If we create variants then store their details in here
    my %variants = ();

    # If we are given a url then fetch the image and create the formats.
    if ( my $source_url = $args->{source_url} ) {

        # Fetch the image
        my $ua  = LWP::UserAgent->new;
        my $res = $ua->get($source_url);

        # Check that we have a successful response
        return unless $res->is_success;
        return unless length $res->content;

        # Work out what the suffix should be
        my $suffix = _mime_type_to_suffix( $res->content_type );

        # save original to tmp file
        my $tmp_original = File::Temp->new( SUFFIX => $suffix );
        $tmp_original->print( $res->content );
        $tmp_original->close;

        # open the original with imlib
        my $imlib       = Image::Imlib2->load($tmp_original);
        my $imlib_ratio = $imlib->width / $imlib->height;

        $variants{original} = {
            meta => join( ',', $imlib->width, $imlib->height, $suffix ),
            mime => $SUFFIX_TO_MIME{$suffix},
            file => $tmp_original,
        };

        # create the variants
        foreach my $format ( keys %FORMATS ) {
            my $spec = $FORMATS{$format};

            # work out which dimension to scale
            my $desired_ratio = $spec->{width} / $spec->{height};

            my ( $width, $height ) =
              $desired_ratio >= $imlib_ratio
              ? ( 0, $spec->{height} )
              : ( $spec->{width}, 0 );

            my $scaled = $imlib->create_scaled_image( $width, $height );

            # get the data from the scaled image
            my $suffix = $spec->{suffix};
            $scaled->image_set_format($suffix);
            my $tmp = File::Temp->new( SUFFIX => ".$suffix" );
            $scaled->save($tmp);

            # create the meta data
            $variants{$format} = {
                meta => join( ',', $scaled->width, $scaled->height, $suffix ),
                mime => $SUFFIX_TO_MIME{$suffix},
                file => $tmp,
            };
        }
    }

    # set the meta for the various formats
    $args->{$_} = $variants{$_}{meta} for qw( original small medium large );

    # create the image in the database (we need the id for the image paths);
    my $image = $rs->next::method($args);

    # now we have an entry in the database we can save the files in the right
    # place
    foreach my $format (qw(original large medium small)) {
        my $path     = $image->key_for($format);
        my $src_file = $variants{$format}{file} . "";
        my $mime     = $variants{$format}{mime};

        my $file_store = YourNextMP->config->{file_store}
          || die "Missing config key 'file_store'";

        if ( $file_store eq 'local' ) {
            my $destination = $STORE_DIR->file($path);
            $destination->dir->mkpath;
            copy( $src_file, $destination->openw );
        }
        elsif ( $file_store eq 's3' ) {
            my $bucket = YourNextMP->s3bucket;
            my $object = $bucket->object(
                key          => $path,
                acl_short    => 'public-read',
                content_type => $mime,
            );
            $object->put_filename($src_file);

        }
        else {
            die "Can't store to file_store '$file_store'";
        }
    }

    # all done - return the image
    return $image;
}

sub _mime_type_to_suffix {
    my $mime_type = shift;

    return $MIME_TO_SUFFIX{$mime_type}
      || die "Could not find suffix for mime_type '$mime_type'";
}

1;
