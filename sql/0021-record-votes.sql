begin;

alter table candidates add column votes integer;
alter table candidates add column is_winner bool;

alter table seats add column votes_recorded bool;
alter table seats add column votes_recorded_when timestamp;

commit;