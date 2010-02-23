begin;

alter table candidates drop column bio;

-- speed things up a little bit
create index candidates_party_id_key on candidates ( party_id );

commit;
