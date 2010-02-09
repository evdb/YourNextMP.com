begin;

-- capture that the user has agreed to assign copyright to YNMP and capture
-- when they agreed to it
alter TABLE users ADD column copyright_granted timestamp;

commit;