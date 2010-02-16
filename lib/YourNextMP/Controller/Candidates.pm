package YourNextMP::Controller::Candidates;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::Candidate;

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $candidates = $c->db('Candidate');

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;

    if ($query) {
        $candidates =
            $query =~ m{\d}
          ? $candidates->search_postcode($query)
          : $candidates->fuzzy_search( { name => $query } );
    }

    $c->stash->{view_all}   = $c->req->param('view_all') || 0;
    $c->stash->{query}      = $query;
    $c->stash->{candidates} = $candidates;

}

sub candidate_base : PathPart('candidates') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $code ) = @_;

    my $candidate = $c->db('Candidate')->find( { code => $code } )
      || $c->detach('/page_not_found');

    $c->stash->{candidate} = $candidate;
}

sub view : PathPart('') Chained('candidate_base') Args(0) {
    my ( $self, $c ) = @_;

}

sub edit : PathPart('edit') Chained('candidate_base') Args(0) {
    my ( $self, $c ) = @_;

    $c->require_user("You must be logged in to add or edit candidates");

    # create a form and stick it on the stash
    my $form =
      YourNextMP::Form::Candidate->new( item => $c->stash->{candidate} );
    $c->stash->{form} = $form;

    return unless $form->process( params => $c->req->params );

    $c->res->redirect( $c->uri_for( '', $c->stash->{candidate}->code ) );

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
