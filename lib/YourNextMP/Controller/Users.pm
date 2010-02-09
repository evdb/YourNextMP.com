package YourNextMP::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::UserEdit;
use DateTime;

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
}

sub user_base : PathPart('users') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub user_retrieve : PathPart('') Chained('user_base') CaptureArgs(1) {
    my ( $self, $c, $user_id ) = @_;

    # Check that the user_id is numeric
    $user_id =~ s{\D}{}g;
    $user_id ||= 0;

    my $user = $c->db('User')->find($user_id)
      || $c->detach('/page_not_found');

    $c->stash->{user} = $user;

}

sub view : PathPart('') Chained('user_retrieve') Args(0) {
    my ( $self, $c ) = @_;

}

sub edit : PathPart('edit') Chained('user_retrieve') Args(0) {
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

=head2 grant_copyright

Before users can use the site they must agree that the copyright of any
contributions they make will belong to YourNextMP so that in the future we can
release it into the public domain.

=cut

sub grant_copyright : Local {
    my ( $self, $c ) = @_;

    # set the xsrf_token if needed
    my $xsrf_token                   #
      = $c->session->{xsrf_token}    #
      ||= int rand 1_000_000_000;

    # check that the form has been submitted correctly
    return unless $c->req->method eq 'POST';
    return unless $c->req->param('xsrf_token') eq $xsrf_token;

    my $agreement = $c->req->param('agreement') || '';
    return unless $agreement eq 'agree' || $agreement eq 'disagree';

    if ( $agreement eq 'agree' ) {
        my $user = $c->user;
        $user->update( { copyright_granted => DateTime->now } );
        $c->return_from_diversion;
    }
    else {
        $c->logout;
        $c->res->redirect('/');
    }

}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
