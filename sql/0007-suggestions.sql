begin;

create table suggestions (
    id          bigint      default nextval('global_id_seq') primary key,

    user_id     bigint      references users(id),
    email       text,
    ip          varchar(20),
    
    referer     text,
    suggestion  text not null,

    type        varchar(20) not null,
    status      varchar(20) not null,

    created     timestamp   not null,
    updated     timestamp   not null
);

commit;
