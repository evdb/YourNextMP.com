begin;

create sequence global_id_seq;

create table seats (
    id          bigint      default nextval('global_id_seq') primary key,
    code        varchar(80) unique,
    created     timestamp   not null,
    updated     timestamp   not null,
    name        varchar(80) not null unique
);

create table files (
    id          bigint      default nextval('global_id_seq') primary key,

    md5         char(32)    not null,
    format      varchar(20) not null,
        unique (md5, format),

    created     timestamp    not null,
    updated     timestamp    not null,
    data        bytea    not null,
    mime_type   varchar(80) not null,
    source      text        not null
);

create table parties (
    id                      bigint      default nextval('global_id_seq') primary key,
    code                    varchar(80) unique,
    created                 timestamp    not null,
    updated                 timestamp    not null,
    name                    varchar(80) not null unique,
    electoral_commision_id  int         unique,
    emblem                  char(32)
);

-- code is the code of the foreign row that the link is related to. ideally
-- we'd have some guarantee that the 'code' is unique across tables but for
-- now we'll just have to hope. note - pg would let us have a sequence we
-- could use across several tables as an id - perhaps migrate?
create table links (
    id          bigint      default nextval('global_id_seq') primary key,
    source      bigint      not null,
    url         text        not null,
        unique( source, url ),
    title       text        not null,
    created     timestamp    not null,
    updated     timestamp    not null
);

create table sessions (
    id           char(72)   primary key,
    session_data text,
    expires      integer,
    created      timestamp    not null,
    updated      timestamp    not null
);

create table users (
    id          bigint      default nextval('global_id_seq') primary key,
    roles       text,

    created     timestamp    not null,
    updated     timestamp    not null,

    openid_identifier   varchar(200) unique,
    email               varchar(200) unique,
    email_confirmed     bool not null default false,

    name                varchar(200),    
    postcode            varchar(10),
    seat_id        bigint references seats(id)
);

create table candidates (
    id          bigint      default nextval('global_id_seq') primary key,
    code        varchar(80) not null unique,
    
    user_id        bigint      references users(id),
    party_id       bigint      not null references parties(id),

    created     timestamp    not null,
    updated     timestamp    not null,

    name        varchar(200),    
    email       varchar(200),
    phone       varchar(200),
    fax         varchar(200),
    address     varchar(200),    
    photo       char(32),
    bio         text
    
);

create table candidacies (
    candidate_id   bigint not null references candidates(id),
    seat_id        bigint not null references seats(id),
        primary key (candidate_id, seat_id),

    created     timestamp    not null,
    updated     timestamp    not null

);

commit;