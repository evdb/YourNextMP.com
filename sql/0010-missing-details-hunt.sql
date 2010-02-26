begin;

-- A script will populate this table by scanning through the candidates for
-- bad details (email, tel, fax, address).

-- A detail can be bad because it is missing. Or it could be a parliamentary
-- address / email which will be disabled after dissolution.

-- A DC volunteer will be given a detail at a time and asked to fix it. When
-- they start the act_after is put an hour ahead so that there is no
-- duplication of effort. Also the act_count wil be incremented so that we can
-- gauge how difficult this detail is to find.

-- If a detail is added then the row relating to it is deleted.

create table bad_details (
    id              serial      primary key,
    candidate_id    bigint      not null references candidates(id),
    detail          varchar(20) not null,
    issue           varchar(20) not null,
    act_after       timestamp   not null,
    act_count       integer     not null  
);

-- no duplicates
create unique index bad_details_candidate_id_detail_key
    on bad_details( candidate_id, detail );

-- fast searching
create index bad_details_candidate_id_key
    on bad_details( candidate_id );

-- fast ordering
create index bad_details_act_after_key
    on bad_details( act_after );

commit;
