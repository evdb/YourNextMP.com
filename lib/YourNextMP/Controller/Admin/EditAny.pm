package YourNextMP::Controller::Admin::EditAny;
use parent 'Catalyst::Controller';

use strict;
use warnings;
use YourNextMP::Form::EditAny;

sub base : Chained('/') PathPart('admin/editany') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # pass through
}

sub get_rs : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $model_name ) = @_;

    # Get the ResultSet to work with
    $c->stash->{rs} = eval { $c->db($model_name) }
      || $c->detach('/page_not_found');

}

sub get_item : Chained('get_rs') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    # Load the item that we are interested in
    $c->stash->{item} = $c->stash->{rs}->find($id)
      || $c->detach('/page_not_found');

}

sub view : Chained('get_item') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    my $rs            = $c->stash->{rs};
    my $item          = $c->stash->{item};
    my $result_source = $item->result_source;

    $c->stash->{item_columns}  = [ $result_source->columns ];
    $c->stash->{relationships} = [ $result_source->relationships ];
}

sub edit : Chained('get_item') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    my $rs            = $c->stash->{rs};
    my $item          = $c->stash->{item};
    my $result_source = $item->result_source;

    # Dynamically create a form to edit this item
    my @field_list =    #
      map { ( $_, { type => 'Text', }, ) }    #
      grep { !m{^(id|updated|created)$} }     #
      $result_source->columns;

    my $form = YourNextMP::Form::EditAny->new(
        item       => $item,
        field_list => [                       #
            @field_list,                      #
            submit => { type => 'Submit' },
        ],
    );
    $c->stash->{form} = $form;

    return if !$form->process( params => $c->req->params );

    # We have an edit - set message in flash and return to referer.
    $c->flash->{message} = "Item has been updated!";
    $c->res->redirect(
          $item->can('path')
        ? $c->uri_for( $item->path )
        : $c->req->referer
    );
    $c->detach;

}

1;
