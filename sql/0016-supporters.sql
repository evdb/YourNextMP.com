begin;

create table supporters (
    id          bigint      default nextval('global_id_seq') primary key,
    user_id     bigint      not null references users(id),

    name        varchar(200)    not null unique,    
    code        varchar(80)     not null unique,
    token       varchar(20)     not null unique,
    level       varchar(20)     not null,
    website     text,
    logo_url    text,
    summary     text,

    created     timestamp    not null,
    updated     timestamp    not null
);

commit;
