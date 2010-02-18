package YourNextMP::ControllerBase;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub result_find : PathPart('') Chained('result_base') CaptureArgs(1) {
    my ( $self, $c, $code ) = @_;

    my $result = $c->db( $self->source_name )->find( { code => $code } )
      || $c->detach('/page_not_found');

    $c->stash->{result} = $result;

}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    my $results = $c->db( $self->source_name );

    my $query = lc( $c->req->param('query') || '' );
    $query =~ s{\s+}{ }g;
    $query =~ s{[^a-z0-9 ]}{}g;

    if ($query) {
        $results =
            $query =~ m{\d}
          ? $results->search_postcode($query)
          : $results->fuzzy_search( { name => $query } );
    }

    $c->stash->{view_all} = $c->req->param('view_all') || 0;
    $c->stash->{query}    = $query;
    $c->stash->{results}  = $results;

}

sub view : PathPart('') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

}

# sub edit : PathPart('edit') Chained('result_find') Args(0) {
#     my ( $self, $c ) = @_;
#
#     $c->require_user("You must be logged in to add or edit XXXX");
#
#     # create a form and stick it on the stash
#     my $form = YourNextMP::Form::result->new( result => $c->stash->{result} );
#     $c->stash->{form} = $form;
#
#     return unless $form->process( params => $c->req->params );
#
#     $c->res->redirect( $c->uri_for( '', $c->stash->{result}->code ) );
#
# }

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
