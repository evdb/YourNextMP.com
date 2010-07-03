#!/bin/bash

cd /var/www/yournextmp_production

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

# ./script/cron/backup_database.pl

# ./script/cron/generate_data_files.pl

# ./script/cron/party_scraper.pl

# ./script/cron/add_hustings_dot_com_links.pl

# ./script/cron/create_sitemap.pl

