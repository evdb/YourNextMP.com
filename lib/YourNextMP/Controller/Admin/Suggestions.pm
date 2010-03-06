package YourNextMP::Controller::Admin::Suggestions;
use parent 'Catalyst::Controller';

use strict;
use warnings;

sub index : Path('') {
    my ( $self, $c ) = @_;
    my $rs = $c->db('Suggestion');

    # mark as done if needed
    if ( my $id = $c->req->param('mark_as_done') ) {
        if ( my $s = $rs->find($id) ) {
            if ( $s->status eq 'new' ) {
                $s->update( { status => 'done' } );
            }
        }
    }

    $c->stash->{results} = $rs->search(    #
        { status   => 'new' },             #
        # { prefetch => ['user'] }
    );

}

1;
