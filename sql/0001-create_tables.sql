begin;

create sequence global_id_seq;

create table seats (
    id          bigint      default nextval('global_id_seq') primary key,
    code        varchar(80) unique,
    created     timestamp   not null,
    updated     timestamp   not null,
    name        varchar(80) not null unique
);

create table images (
    id          bigint       default nextval('global_id_seq') primary key,

    source_url  text         unique,
    small       varchar(200) not null,
    medium      varchar(200) not null,
    large       varchar(200) not null,
    original    varchar(200) not null,

    created     timestamp    not null,
    updated     timestamp    not null
);

create table parties (
    id                      bigint      default nextval('global_id_seq') primary key,
    code                    varchar(80) unique,
    created                 timestamp    not null,
    updated                 timestamp    not null,
    name                    varchar(80) not null unique,
    electoral_commision_id  int         unique,
    image_id                bigint references images(id)
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
    image_id    bigint references images(id),
    bio         text,
    
    scrape_source varchar(300) unique,
    can_scrape    bool not null default true
    
);

create table candidacies (
    candidate_id   bigint not null references candidates(id),
    seat_id        bigint not null references seats(id),
        primary key (candidate_id, seat_id),

    created     timestamp    not null,
    updated     timestamp    not null

);

commit;