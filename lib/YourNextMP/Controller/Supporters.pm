package YourNextMP::Controller::Supporters;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

use YourNextMP::Form::SupporterAdd;

sub result_base : PathPart('supporters') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Supporter';
}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    # gather the supporters from the various levels
    my @levels     = qw( platinum gold silver bronze );
    my $supporters = {};

    foreach my $level (@levels) {
        $supporters->{$level}      #
          = $c->db('Supporter')    #
          ->search( { level => $level } )    #
          ->as_data;
    }

    $c->stash->{supporters} = $supporters;

}

sub add : PathPart('add') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to access our data");

    # create the form and place it on the stash
    my $item = $c->db('Supporter')->new_result( {} );
    $item->user_id( $c->user->id );
    my $form = YourNextMP::Form::SupporterAdd->new( item => $item );
    $c->stash( form => $form );

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    # go to supporter page
    $c->res->redirect( $c->uri_for( '/supporters', $item->code ) );
    $c->detach;

}

1;
