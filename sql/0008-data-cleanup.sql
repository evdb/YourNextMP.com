begin;

delete from candidacies
    where candidate_id in (select id from candidates where code = '');

delete from candidates where code = '';

update parties
    set name = regexp_replace( name, '......$', '' )
    where name ilike '% [the]';

commit;
