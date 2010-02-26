begin;

alter table link_relations drop constraint link_relations_pkey;

create unique index link_relations_link_id_foreign_id_key
    on link_relations ( link_id, foreign_id );

alter table link_relations
    add column id bigint primary key
        default nextval('global_id_seq');

commit;
