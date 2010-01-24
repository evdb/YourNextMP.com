create table seats (
    code        varchar(80) primary key,
    created     datetime    not null,
    updated     datetime    not null,
    name        varchar(80) not null unique
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table files (
    md5         char(32)    not null,
    format      varchar(20) not null,
        primary key (md5, format),
    created     datetime    not null,
    updated     datetime    not null,
    data        longblob    not null,
    mime_type   varchar(80) not null,
    source      text        not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table parties (
    code                    varchar(80) primary key,
    created                 datetime    not null,
    updated                 datetime    not null,
    name                    varchar(80) not null unique,
    electoral_commision_id  int         unique,
    emblem                  char(32)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- code is the code of the foreign row that the link is related to. Ideally
-- we'd have some guarantee that the 'code' is unique across tables but for
-- now we'll just have to hope. Note - PG would let us have a sequence we
-- could use across several tables as an id - perhaps migrate?
create table links (
    id          serial      primary key,
    code        varchar(80) not null,
    url         text        not null,
    title       text        not null,
    created     datetime    not null,
    updated     datetime    not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT,
    expires      INTEGER,
    created      datetime    not null,
    updated      datetime    not null
)  ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE users (
    id                  SERIAL PRIMARY KEY,
    roles               TEXT,

    created     datetime    not null,
    updated     datetime    not null,

    openid_identifier   varchar(200) unique,
    email               varchar(200) unique,
    email_confirmed     bool not null default 0,

    name                varchar(200),    
    postcode            varchar(10),
    seat        varchar(80),
        foreign key (seat)  references seats(code)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE candidates (
    code        varchar(80) primary key,

    user        integer,
    party       varchar(80) not null,
        foreign key (user)  references users(id),
        foreign key (party) references parties(code),

    created     datetime    not null,
    updated     datetime    not null,

    name        varchar(200),    
    email       varchar(200),
    phone       varchar(200),
    fax         varchar(200),
    address     varchar(200),    
    photo       char(32),
    bio         text
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE candidacies (
    candidate       varchar(80) not null,
    seat    varchar(80) not null,
        primary key (candidate, seat),
        foreign key (candidate)     references candidates(code),
        foreign key (seat)          references seats(code),

    created     datetime    not null,
    updated     datetime    not null

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

