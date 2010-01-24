#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 13;
use Test::WWW::Mechanize::Catalyst 'YourNextMP';
use JSON;

my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/');

# check that we can get an HTML result
$mech->get_ok('/seats');
$mech->submit_form(
    form_name => 'seat_search',         #
    fields => { query => 'SW15 3SX' }
);
$mech->content_contains( 'Putney', "Found putney constituency" );
is $mech->response->content_type, 'text/html', 'got html';

# add output=json to the url
my $json_url = $mech->uri . '&output=json';
pass $json_url;
$mech->get_ok($json_url);
is $mech->response->content_type, 'application/json', 'got json';

my $data = JSON->new->decode( $mech->content );
ok $data, "decoded json";
is_deeply $data->{result}, [ { code => 'putney', name => 'Putney' } ],
  "got expected results";

# check that the callback works too
my $json_callback_url = $mech->uri . '&output=json&json_callback=cb';
pass $json_callback_url;
$mech->get_ok($json_callback_url);
is $mech->response->content_type, 'application/json', 'got json';
like $mech->content, qr{ \A cb\( .* \); \z}xms, "wrapped data in callback";

