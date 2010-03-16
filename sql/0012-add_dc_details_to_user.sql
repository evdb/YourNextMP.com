begin;

alter table users add column dc_id integer unique;

commit;
