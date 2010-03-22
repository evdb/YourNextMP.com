package YourNextMP::Controller::Admin::Candidate;
use parent 'Catalyst::Controller';

use strict;
use warnings;

sub base : Chained('/') PathPart('admin/candidate') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub get_candidate : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $candidate = $c->db('Candidate')->find($id)
      || $c->detach('/page_not_found');

    $c->stash->{result} = $candidate;
}

sub stand_down : Chained('get_candidate') PathPart('stand_down') Args(0) {
    my ( $self, $c, $id ) = @_;
    my $candidate = $c->stash->{result};

    $c->stash->{template} = 'admin/confirm_action.html';
    $c->stash->{message}  = "Is " . $candidate->name . " really standing down?";

    return unless $c->req->method eq 'POST';

    $candidate->update( { status => 'standing_down' } );
    $c->flash->{message} = "Stood down";
    $c->res->redirect( $c->uri_for( $candidate->path ) );
}

1;
