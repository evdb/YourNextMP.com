begin;

alter table candidates add column votes integer;

alter table seats add column votes_recorded bool;

commit;