#!/bin/bash

cd /var/www/yournextmp_production

./script/cron/backup_database.pl

./script/cron/create_sitemap.pl

./script/cron/generate_data_files.pl
