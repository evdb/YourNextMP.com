package YourNextMP::Controller::Links;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

use YourNextMP::Form::LinkEdit;
use DateTime;

sub result_base : PathPart('links') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Link';
}

sub edit : PathPart('edit') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_admin_user("Please log in to edit links");

    # Get the link we are looking at
    my $link = $c->stash->{result};

    # create a form and stick it on the stash
    my $form = YourNextMP::Form::LinkEdit->new( item => $link );
    $c->stash->{form} = $form;

    # the "process" call has all the saving logic,
    #   if it returns False, then a validation error happened
    return unless $form->process( params => $c->req->params );

    # $c->flash->{info_msg} = "Article saved!";
    $c->res->redirect( $c->uri_for( $link->id ) );
}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
