begin;

alter table candidates add column status text not null default 'standing';

commit;
