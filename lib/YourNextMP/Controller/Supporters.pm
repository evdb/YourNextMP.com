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

# sub search_for_results {
#     my ( $self, $results, $query ) = @_;
#     $results->standing->fuzzy_search( { name => $query } );
# }

sub add : PathPart('add') Chained('result_base') Args(0) {
    my ( $self, $c ) = @_;

    # We need logged in users to create candidates
    $c->require_user("Please log in to access our data");

    # create the form and place it on the stash
    my $item = $c->db('Supporter')->new_result( {} );
    $item->user( $c->user->obj );
    my $form = YourNextMP::Form::SupporterAdd->new( item => $item );
    $c->stash( form => $form );

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    # go to supporter page
    $c->res->redirect( $c->uri_for( '/supporters', $item->code ) );
    $c->detach;

}

# sub edit_details : PathPart('edit_details') Chained('result_find') Args(0) {
#     my ( $self, $c ) = @_;
#
#     # We need logged in users to create candidates
#     $c->require_user("Please log in to edit candidate details");
#
#     # create the form and place it on the stash
#     my $candidate = $c->stash->{result};
#     my $form =
#       YourNextMP::Form::CandidateEditDetails->new( item => $candidate );
#     $c->stash( form => $form );
#
#     # process the form and return if there were errors
#     return if !$form->process( params => $c->req->params );
#
#     # We have a new candidate
#     $candidate->update( { can_scrape => 0 } );
#     $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
#     $c->detach;
#
# }
#
# sub edit_photo : PathPart('edit_photo') Chained('result_find') Args(0) {
#     my ( $self, $c ) = @_;
#
#     # We need logged in users to create candidates
#     $c->require_user("Please log in to edit candidate photo");
#
#     # create the form and place it on the stash
#     my $candidate = $c->stash->{result};
#     my $form = YourNextMP::Form::CandidateEditPhoto->new( item => $candidate );
#     $c->stash( form => $form );
#
#     # If it is not a post then return
#     return unless $c->req->method eq 'POST';
#
#     # gather all the parameters - including the uploaded file if posted
#     my $params = $c->req->params;
#     my $upload = $c->req->upload('photo_upload');
#     $params->{photo_upload} = $upload if $upload;
#
#     # process the form and return if there were errors
#     return if !$form->process( params => $params );
#
#     # We have a new candidate
#     $candidate->update( { can_scrape => 0 } );
#     $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
#     $c->detach;
#
# }
#
# sub edit_personal : PathPart('edit_personal') Chained('result_find') Args(0) {
#     my ( $self, $c ) = @_;
#
#     # We need logged in users to create candidates
#     $c->require_user("Please log in to edit candidate's personal details");
#
#     # create the form and place it on the stash
#     my $candidate = $c->stash->{result};
#     my $form =
#       YourNextMP::Form::CandidateEditPersonal->new( item => $candidate );
#     $c->stash( form => $form );
#
#     # process the form and return if there were errors
#     return if !$form->process( params => $c->req->params );
#
#     $c->res->redirect( $c->uri_for( '/candidates', $candidate->code ) );
#     $c->detach;
#
# }

1;
