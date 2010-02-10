begin;

alter table candidacies drop constraint candidacies_pkey;
alter table candidacies add column id serial primary key;
create unique index candidacies_seat_id_candidate_id_key on candidacies (seat_id , candidate_id);


create table edits (
    id              serial          primary key,
    source_table    varchar(100)    not null,
    source_id       bigint          not null,

    created         timestamp       not null,
    updated         timestamp       not null,
    edited          float           not null,
    
    edit_type       varchar(10)     not null, --insert, update, delete
    
    data            text            not null,
    
    user_id         bigint          references users(id),
    comment         text
);

commit;
