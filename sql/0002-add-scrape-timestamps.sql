begin;

alter table candidates add last_scraped timestamp;

commit;