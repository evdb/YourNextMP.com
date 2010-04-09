package YourNextMP::ControllerBase;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::LinkAdd;

sub result_find : PathPart('') Chained('result_base') CaptureArgs(1) {
    my ( $self, $c, $value ) = @_;
    $c->can_do_output('json');

    # If the value is numeric assume it is an id - otherwise a code
    my $key = $value =~ m{\D} ? 'code' : 'id';

    # check that the rs has the key requested (if code)
    my $rs = $c->db( $self->source_name );

    # Check that we can do a code lookup
    $c->detach('/page_not_found')
      if $key ne 'id'
          && !$rs->result_source->has_column($key);

    my $result =    #
      $rs->find( { $key => $value } )
      || $c->detach('/page_not_found');

    $c->stash->{result} = $result;

}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;
}

sub by_id : PathPart('by_id') Chained('result_base') Args(1) {
    my ( $self, $c, $id ) = @_;
    my $rs = $c->db( $self->source_name );
    my $result = $rs->find( { id => $id } )
      || $c->detach('/page_not_found');
    $c->res->redirect( $c->uri_for( $result->path ) );
}

sub search : PathPart('search') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    $c->can_do_output('json');

    my $results = $c->db( $self->source_name );

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;
    $c->stash->{query} = $query;

    if ($query) {
        $results = $self->search_for_results( $results, $query, $c );
        $c->stash->{results} = $results;
    }

    # If there is only one result then redirect to it (if web page)
    if ( $results && $results->count == 1 && $c->output_is('html') ) {
        $c->res->redirect( $c->uri_for( $results->first->code ) );
        $c->detach;
    }
}

sub all_empty : PathPart('all') Chained('result_base') {
    my ( $self, $c ) = @_;

    $c->res->redirect( $c->uri_for( 'all', 1 ) );
    $c->detach;
}

sub all : PathPart('all') Chained('result_base') Args(1) {
    my ( $self, $c, $page_number ) = @_;

    $c->can_do_output('json');

    my $results_per_page = 50;

    # clean up the page_number
    $page_number =~ s{\D+}{}g;
    $page_number ||= 1;

    my $results = $c->db( $self->source_name )->search(
        undef,    # find everything
        {
            rows => $results_per_page,
            page => $page_number,
        }
    );

    # check that we have not gone beyond the end of the list
    if ( $page_number > $results->pager->last_page ) {
        $c->res->redirect( $c->uri_for( 'all', $results->pager->last_page ) );
        $c->detach;
    }

    $c->stash->{pager}   = $results->pager;
    $c->stash->{results} = $results;
}

sub search_for_results {
    my ( $self, $results, $query, $c ) = @_;
    $results->fuzzy_search( { name => $query } );
}

sub view : PathPart('') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

}

sub add_link : PathPart('add_link') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->require_user("Please log in to add links");

    # create a form and stick it on the stash
    my $form = YourNextMP::Form::LinkAdd->new();
    $c->stash->{form}     = $form;
    $c->stash->{template} = 'generic/add_link.html';

    # check the form
    return unless $form->process( params => $c->req->params );

    # have a url from form - find or create the link
    my $link =
      $c->db('Link')->find_or_create( { url => $form->field('url')->value } );

    # make sure that the link is attached to our result
    my $result = $c->stash->{result};
    $link->find_or_create_related(
        link_relations => {
            foreign_id    => $result->id,
            foreign_table => $result->table
        }
    );

    # redirect to the link edit page
    $c->res->redirect( $c->uri_for( $link->path, 'edit' ) );
}

sub history : PathPart('history') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->require_user("Please log in to see the history");

    $c->stash->{template} = 'generic/history.html';
    $c->stash->{results}  = $c->stash->{result}->edits;

}

1;
