#!/bin/bash

cd /var/www/yournextmp_production

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

./script/cron/party_scraper.pl