package YourNextMP::Scrapers::ScraperBase;

use strict;
use warnings;

use App::Cache;

sub cache {
    return App::Cache->new(
        {
            ttl => 3600 * 12    # 12 hours
        }
    );
}

1;
