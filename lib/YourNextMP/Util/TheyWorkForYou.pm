package YourNextMP::Util::TheyWorkForYou;

use strict;
use warnings;

use WebService::TWFY::API;
use Carp;
use JSON;
use Encode;

use Object::Signature;
use YourNextMP::Util::Cache;

my $KEY = 'AKsVdyDP9HcQCp6jCuE3tL66';
my $twfy = WebService::TWFY::API->new( { key => $KEY } );

sub new {
    return bless {}, shift;
}

sub query {
    my $self   = shift;
    my $method = shift;
    my $args   = shift;

    $args->{output} = 'js';

    my $sig = Object::Signature::signature($args);
    warn $sig;
    
    my $results = YourNextMP::Util::Cache->cache->get_code(
        "twfy_api:$sig",
        sub {
            my $result = $twfy->query( $method, $args );

            croak "TWFY error: $result->{error_message} calling '$method'"
              unless $result && $result->{is_success};

            my $json_string = $result->{results};

            # $json_string = encode_utf8( decode( 'latin1', $json_string ) );

            my $results = JSON->new->latin1->decode($json_string);
            return $results;
        }
    );

    return $results;
}

1;
