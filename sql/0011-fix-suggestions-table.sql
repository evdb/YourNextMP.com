begin;

-- ip addresses can be longer if they are IPv6 - use text to be safe
alter table suggestions alter ip type text;

commit;
