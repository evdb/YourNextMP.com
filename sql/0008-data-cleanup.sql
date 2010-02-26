begin;

delete from candidacies
    where candidate_id in (select id from candidates where code = '');

delete from candidates where code = '';

commit;
