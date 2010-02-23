begin;

-- create the link_relations table so that one link can be associated with
-- several objects
create table link_relations (
    foreign_id   bigint not null,
    link_id      bigint not null references links(id),
        primary key (foreign_id, link_id),

        created     timestamp    not null,
        updated     timestamp    not null
);

-- data cleanup
delete from links
    where id in (
        select a.id from links a, links b
        where a.url = b.url
          and a.id != b.id
    );


-- move existing data from links to link_relations
insert into link_relations 
    select source, id, created, updated from links;
alter table links drop column source;

-- add extra fields
alter table links add column summary text;
alter table links add column published timestamp;
alter table links add column link_type varchar(10);
update      links set link_type = 'info';
alter table links alter link_type set not null;

commit;
