begin;

alter table seats
    add column nomination_url  text,
    add column nominated_count integer,
    add column nominations_entered bool;

commit;