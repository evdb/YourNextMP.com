package YourNextMP::Controller::Suggestions;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::SuggestionAdd;

sub add : Local {
    my ( $self, $c ) = @_;

    # create the form and place it on the stash
    my $item = $c->db('Suggestion')->new_result( {} );
    my $form = YourNextMP::Form::SuggestionAdd->new( item => $item );
    $c->stash( form => $form );

    # Add defaults to the item
    $item->ip( $c->req->address );
    $item->user_id( $c->user->id ) if $c->user;
    $item->status('new');

    # Combine the GET and POST parameters
    my $params = {
        %{ $c->req->query_parameters },    # GET
        %{ $c->req->body_parameters },     # POST (overides GET)
    };

    # process the form and return if there were errors
    return if !$form->process( params => $params );

    # We have a new suggestion - set message in flash and return to referer.
    $c->flash->{message} = "Thanks - your suggestion has been saved.";
    $c->res->redirect( $item->referer || $c->uri_for('/') );
    $c->detach;
}

1;
