package YourNextMP::Controller::Suggestions;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use YourNextMP::Form::SuggestionAdd;

sub add : Local {
    my ( $self, $c ) = @_;
    my $user = $c->user;

    # create the form and place it on the stash
    my $item = $c->db('Suggestion')->new_result( {} );
    my $form = YourNextMP::Form::SuggestionAdd->new( item => $item );
    $c->stash( form => $form );

    # Add defaults to the item
    $item->ip( $c->req->address );
    $item->status('new');

    # If we have a user we can pre-fill some details
    if ($user) {
        $item->user_id( $user->id );
    }

    # If we have a user we can pre-fill some details
    my %defaults = ();
    if ($user) {
        $defaults{email} = $user->email;
    }

    # Combine the GET and POST parameters
    my $params = {
        %defaults,                         # email etc
        %{ $c->req->query_parameters },    # GET
        %{ $c->req->body_parameters },     # POST (overides GET)
    };

    # process the form and return if there were errors
    return if !$form->process( params => $params );

    # Add email to user if missing

    $user->update( { email => $form->field('email')->value } )
      if $user
          && !$user->email
          && $form->field('email')->value;

    # We have a new suggestion - set message in flash and return to referer.
    $c->flash->{message} = "Thanks - your suggestion has been saved.";
    $c->res->redirect( $item->referer || $c->uri_for('/') );
    $c->detach;
}

1;
