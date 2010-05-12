package YourNextMP::Controller::Tools;
use parent 'Catalyst::Controller';

use strict;
use warnings;

sub set_gender : Local {
    my ( $self, $c ) = @_;

    $c->require_user('Please log in to set the genders');

    my $id = $c->req->param('id');
    my $gender = lc( $c->req->param('gender') || '' );

    if ( $id && $gender && $gender =~ m{^(?:male|female)$} ) {
        my $candidate = $c->db('Candidate')->find($id);
        $candidate->update( { gender => $gender } );
    }

    my $rs = $c->db('Candidate')->search( { gender => undef } );

    $c->stash->{candidate} = $rs->random;
    $c->stash->{count}     = $rs->count;
}

1;
