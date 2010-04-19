begin;

create table code_renames (
    id          bigint      default nextval('global_id_seq') primary key,
    old_code    varchar(80) not null unique,
    new_code    varchar(80) not null
);

commit;