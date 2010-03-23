begin;

alter table users add column password text;
alter table users add column token    text;

commit;