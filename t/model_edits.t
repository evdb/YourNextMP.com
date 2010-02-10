#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 20;

use YourNextMP;

# create a new candidate
my $party = YourNextMP->db('Party')->find( { code => 'independent' } );
my $candidate = YourNextMP->db('Candidate')->find_or_create(
    {
        code     => 'joe_bloggs',
        name     => 'Joe Bloggs',
        party_id => $party->id,
    }
);
ok $candidate, "Created the candidate";

# check that there is an entry in the edits table
is $candidate->edits->count, 1, "Found one edit";
is $candidate->edits->first->data->{name}, "Joe Bloggs", "name correct";

# update the candidate
ok $candidate->update( { name => "Joe Bloggs 2" } ), "change name";

# check that the old edit is unchanged and the new one recorded
is $candidate->edits->first->data->{name}, "Joe Bloggs",   "first name correct";
is $candidate->edits->last->data->{name},  "Joe Bloggs 2", "last name correct";

# check that there is no user or comment
is $candidate->edits->last->user,    undef, "no user stored";
is $candidate->edits->last->comment, undef, "no comment stored";

# set the user
my $user =
  YourNextMP->db('User')->find_or_create( { openid_identifier => 'test' } );
YourNextMP->edit_user($user);
YourNextMP->edit_comment('this is a comment');

# update with a user and comment
ok $candidate->update( { name => "Joe Bloggs 3", } ),
  "change name (with user and comment)";

# check that the  user and comment are recorded
is $candidate->edits->last->user->id, $user->id, "user stored";
is $candidate->edits->last->comment, 'this is a comment', "comment stored";

# clear the user
YourNextMP->clear_edit_details;

# update with a user and comment
ok $candidate->update( { name => "Joe Bloggs 4", } ),
  "change name (with user and comment)";

# check that there is no user or comment
is $candidate->edits->last->user,    undef, "no user stored";
is $candidate->edits->last->comment, undef, "no comment stored";

# delete the candidate
my $candidate_id = $candidate->id;
ok $candidate_id, "got a candidate_id $candidate_id";
ok $candidate->delete, "delete the candidate";

# check that the edits remain and there is a delete edit
my $edit_rs = YourNextMP->db('Edit');

my $delete_edit = $edit_rs->search(
    {
        source_table => 'candidates',
        source_id    => $candidate_id,
        edit_type    => 'delete'
    }
)->first;
ok $delete_edit, "Found the delete edit";
is_deeply $delete_edit->data, {}, "no data";

my $candidate_edits = $edit_rs->search( { source_id => $candidate_id } );
is $candidate_edits->count, 5, "all edits stored";

# clean up the edits and user
ok $edit_rs->search( { source_id => $candidate_id } )->delete_all,
  'delete test edits (candidate)';

