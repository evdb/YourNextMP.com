begin;

alter table candidates add column birthplace text;

alter table parties rename column electoral_commision_id to gb_id;
alter table parties add column ni_id int;

alter table parties drop constraint parties_electoral_commision_id_key;
create unique index parties_gb_id_key on parties(gb_id);
create unique index parties_ni_id_key on parties(ni_id);

commit;