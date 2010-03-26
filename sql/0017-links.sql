begin;

alter table links alter column title drop not null;

create unique index links_url_key on links (url);
    
commit;
