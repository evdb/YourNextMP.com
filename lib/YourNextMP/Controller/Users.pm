package YourNextMP::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::UserEdit;

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

}

sub user_base : PathPart('users') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $user_id ) = @_;

    my $user = $c->db('User')->find($user_id)
      || $c->detach('/page_not_found');

    $c->stash->{user} = $user;

}

sub view : PathPart('') Chained('user_base') Args(0) {
    my ( $self, $c ) = @_;

}

sub edit : PathPart('edit') Chained('user_base') Args(0) {
    my ( $self, $c ) = @_;

    # Get the user we are looking at
    my $user = $c->stash->{user};

    # can we be here?
    $c->divert_to( $c->uri_for('/auth/login') )
      unless $c->user && $c->user->id == $user->id;

    # create a form and stick it on the stash
    my $form = YourNextMP::Form::UserEdit->new( item => $user );
    $c->stash->{form} = $form;

    # the "process" call has all the saving logic,
    #   if it returns False, then a validation error happened
    return unless $form->process( params => $c->req->params );

    # $c->flash->{info_msg} = "Article saved!";
    $c->res->redirect( $c->uri_for( '', $user->id ) );
}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
