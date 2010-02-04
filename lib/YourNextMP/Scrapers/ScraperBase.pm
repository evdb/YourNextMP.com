package YourNextMP::Scrapers::ScraperBase;

use strict;
use warnings;

use YourNextMP::Util::Cache;
use List::Util qw( first );

use Module::Pluggable
  sub_name    => 'scrapers',
  search_path => ['YourNextMP::Scrapers'],
  require     => 1,
  except      => 'YourNextMP::Scrapers::ScraperBase';

my @SCRAPERS = __PACKAGE__->scrapers;

sub cache {
    return YourNextMP::Util::Cache->cache;
}

sub find_candidate_scraper {
    my $class = shift;
    my $url   = shift;
    return first { $_->can_do_candidate_url($url) } @SCRAPERS;
}

sub find_candidate_list_scraper {
    my $class = shift;
    my $code  = shift;
    return first { $_->can_do_candidate_list($code) } @SCRAPERS;
}

1;
