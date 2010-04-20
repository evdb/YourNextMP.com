package YourNextMP::Controller::Candidates;

use strict;
use warnings;
use parent 'YourNextMP::ControllerBase';

use YourNextMP::Form::CandidateAdd;
use YourNextMP::Form::CandidateEditDetails;
use YourNextMP::Form::EditPhoto;
use YourNextMP::Form::CandidateEditPersonal;

sub result_base : PathPart('candidates') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Candidate';
}

sub search_for_results {
    my ( $self, $results, $query ) = @_;
    $results->standing->fuzzy_search( { name => $query } );
}

sub index : PathPart('') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{results}    #
      = $c                  #
      ->db('Candidate')     #
      ->standing            #
      ->search( undef, { order_by => 'updated desc', rows => 30 } );
}

sub add : PathPart('add') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to create a new candidate");

    # create the form and place it on the stash
    my $item = $c->db('Candidate')->new_result( {} );
    my $form = YourNextMP::Form::CandidateAdd->new( item => $item );
    $c->stash( form => $form );

    # Combine the GET and POST parameters
    my $params = {
        %{ $c->req->query_parameters },    # GET
        %{ $c->req->body_parameters },     # POST (overides GET)
    };

    # Check that the code created will not clash with an existing candidate
    if ( my $name = $params->{name} ) {
        my $code = $c->db('Candidate')->name_to_code($name);

        if ( $c->db('Candidate')->find( { code => $code } ) ) {
            $c->res->redirect( $c->uri_for( '/candidates', $code ) );
            $c->detach;
        }
    }

    # process the form and return if there were errors
    return if !$form->process( params => $params );

    # We have a new candidate - send user to edit page to add more details

    # check that we should not send back json
    if ( ( $c->req->param('output') || '' ) eq 'json' ) {
        $c->can_do_output('json');
        $c->stash->{json_result} = {
            id    => $item->id,
            name  => $item->name,
            party => $item->party->name,
        };
    }
    else {
        $c->res->redirect(
            $c->uri_for( '/candidates', $item->code, 'edit_details' ) );
    }

    $c->detach;

}

sub add_json : PathPart('add_json') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to create a new candidate");
    $c->can_do_output('json');
    $c->stash->{output} = 'json';

    # create the form and place it on the stash
    my $item = $c->db('Candidate')->new_result( {} );
    my $form = YourNextMP::Form::CandidateAdd->new( item => $item );

    # Check that the code created will not clash with an existing candidate
    if ( my $name = $c->req->param('name') ) {
        my $code = $c->db('Candidate')->name_to_code($name);

        if ( $c->db('Candidate')->find( { code => $code } ) ) {
            $c->stash->{json_result} = {    #
                error => 'duplicate'
            };
            return;
        }
    }

    # process the form and return if there were errors
    if ( $form->process( params => $c->req->params ) ) {
        $c->stash->{json_result} = {
            id    => $item->id,
            name  => $item->name,
            party => $item->party->name,
        };
    }
    else {
        $c->stash->{json_result} = {    #
            error => 'other'
        };
    }

}

sub edit_details : PathPart('edit_details') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to edit candidate details");

    # create the form and place it on the stash
    my $candidate = $c->stash->{result};
    my $form =
      YourNextMP::Form::CandidateEditDetails->new( item => $candidate );
    $c->stash( form => $form );

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    # We have a new candidate
    $candidate->update( { can_scrape => 0 } );
    $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
    $c->detach;

}

sub edit_photo : PathPart('edit_photo') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to edit candidate photo");

    # create the form and place it on the stash
    my $candidate = $c->stash->{result};
    my $form = YourNextMP::Form::EditPhoto->new( item => $candidate );
    $c->stash( form => $form );

    # If it is not a post then return
    return unless $c->req->method eq 'POST';

    # gather all the parameters - including the uploaded file if posted
    my $params = $c->req->params;
    my $upload = $c->req->upload('photo_upload');
    $params->{photo_upload} = $upload if $upload;

    # process the form and return if there were errors
    return if !$form->process( params => $params );

    # We have a new candidate
    $candidate->update( { can_scrape => 0 } );
    $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
    $c->detach;

}

sub edit_personal : PathPart('edit_personal') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to edit candidate's personal details");

    # create the form and place it on the stash
    my $candidate = $c->stash->{result};
    my $form =
      YourNextMP::Form::CandidateEditPersonal->new( item => $candidate );
    $c->stash( form => $form );

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
    $c->detach;

}

1;
