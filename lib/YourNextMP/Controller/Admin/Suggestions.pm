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
        { status => 'new' },               #
                                           # { prefetch => ['user'] }
    );
}

sub view : Local {
    my ( $self, $c, $id ) = @_;
    my $rs = $c->db('Suggestion');

    my $suggestion = $rs->find($id)
      || return $c->res->redirect( $c->uri_for('') );
    $c->stash->{result} = $suggestion;

    # work out what we should do
    my $mark_as_done = $c->req->param('done') ? 1 : 0;
    my $skip_on      = $c->req->param('skip') ? 1 : 0;

    if ($mark_as_done) {
        $suggestion->update( { status => 'done' } );
        $skip_on = 1;
    }

    if ($skip_on) {
        my $next_suggestion = $rs->search(    #
            {
                status => 'new',
                id     => { '>' => $suggestion->id }
            },
            {
                rows     => 1,
                order_by => 'id',
            }
        )->first;

        $next_suggestion
          ? $c->res->redirect( $c->uri_for( 'view', $next_suggestion->id ) )
          : $c->res->redirect( $c->uri_for('') );
    }
}

1;
