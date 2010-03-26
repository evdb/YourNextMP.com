package YourNextMP::Form::Field::WebAddress;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use Regexp::Common qw /URI/;
use LWP::UserAgent;

apply(
    [
        {
            transform => sub {
                my $url = shift;
                return $url =~ m{^http://} ? $url : "http://$url";
            },
        },
        {
            check => sub {
                my $url = shift;
                return $url =~ m{^$RE{URI}{HTTP}$};
            },
            message =>
              "This is not a valid url - expecting 'http://example.com/'",
        },
        {
            check => sub {
                my $url = shift;

                # create a useragent and pretend to be a real browser
                my $ua = LWP::UserAgent->new(
                    agent =>
'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-GB; rv:1.9.1.8) Gecko/20100202 Firefox/3.5.8',
                    from => 'hello@yournextmp.com',
                    max_size => 16 * 1024,    # 16kB only to check it exists
                    timeout  => 10,           # short - don't want to block site
                );

                # do a get on the url - somesites don't like heads
                my $res = $ua->get($url);

                # did we get a good response?
                return $res->is_success;
            },
                message => "We tried to fetch this url but got an error"
              . " - please check it is correct and does not require a"
              . " login to view it",

        }
    ]
);

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
