begin;

alter table candidates add column dob        text;
alter table candidates add column gender     text;
alter table candidates add column school     text;
alter table candidates add column university text;
alter table candidates add column positions  text;

commit;
