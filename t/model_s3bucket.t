#!/usr/bin/perl -w

use strict;
use Test::More tests => 7;

use YourNextMP;
use LWP::UserAgent;
use Path::Class;

my $bucket = YourNextMP->s3bucket;
isa_ok $bucket, 'Net::Amazon::S3::Client::Bucket';

# save a file to the store and retrieve it
my $object = $bucket->object(
    key          => 'testing/public_test_object',
    acl_short    => 'public-read',
    content_type => 'text/plain'
);
$object->put_filename(__FILE__);
ok $object, "created an object";

# cleanup
END { ok $object->delete, "deleted the object"; }

# check that we can retrieve the object
my $uri = $object->uri;
ok $uri, "got a uri: $uri";

my $res = LWP::UserAgent->new->get($uri);
ok $res->is_success,   "retrieved the object";
is $res->content_type, 'text/plain', "content_type correct";
is $res->content,      scalar file(__FILE__)->slurp, "content correct";

