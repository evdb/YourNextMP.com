package YourNextMP::Controller::Seats;
use parent 'YourNextMP::ControllerBase';

use strict;
use warnings;

use YourNextMP::Form::AddNominationURL;
use YourNextMP::Form;
use DateTime;

sub result_base : PathPart('seats') Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub source_name {
    return 'Seat';
}

sub search_for_results : Private {
    my ( $self, $seats, $query, $c ) = @_;
    if ( $query =~ m{\d} ) {
        $c->flash->{searched_by_postcode} = 1;
        return $seats->search_postcode($query);
    }
    else {
        return $seats->fuzzy_search( { name => $query } );
    }
}

sub view : PathPart('') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{candidates} = $c->stash->{result}->candidates->standing;

}

sub add_nomination_url : PathPart('add_nomination_url') Chained('result_find')
  Args(0) {
    my ( $self, $c ) = @_;

    $c->require_admin_user("Please log in to add nomination details");

    my $seat = $c->stash->{result};
    my $form = YourNextMP::Form::AddNominationURL->new( item => $seat );
    $c->stash( form => $form );

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    # we have the url - now send the user to the page to check the candidates
    $c->res->redirect( $c->uri_for( $seat->path, 'nominate_candidates' ) );
    $c->detach;
}

sub nominate_candidates : PathPart('nominate_candidates') Chained('result_find')
  Args(0) {
    my ( $self, $c ) = @_;

    $c->require_admin_user("Please log in to flag nominated candidates");

    $c->stash->{parties} =
      $c->db('Party')->search( undef, { columns => [ 'id', 'name' ] } );

    # If it is not a post then return
    return unless $c->req->method eq 'POST';

    my $seat = $c->stash->{result};

    # get all the candidates into a hash id => object
    my %candidates = map { $_->id => $_ } $seat->candidates;

    # go through all the candidates nominated and set them to be standing
    my @nominated_ids = $c->req->param('nominated');
    foreach my $nominated_id (@nominated_ids) {
        my $candidate = delete $candidates{$nominated_id};

        next if !$candidate    #
              || $candidate->is_standing;

        $candidate->update( { status => 'standing' } );
    }

    # go through remaining candidates and mark as 'not-nominated' if needed
    foreach my $not_nominated_candidate ( values %candidates ) {
        next unless $not_nominated_candidate->is_standing;
        $not_nominated_candidate->update( { status => 'not-standing' } );
    }

    # flag this seat as being processed
    $seat->update( { nominations_entered => 1 } );

    # all done - return to the seat
    $c->res->redirect( $c->uri_for( $seat->path ) );
    $c->detach;
}

sub record_votes : PathPart('record_votes') Chained('result_find') Args(0) {
    my ( $self, $c ) = @_;

    $c->require_user('Please log in to record votes');

    my $seat       = $c->stash->{result};
    my @candidates = $seat->candidates->standing->all;

    # create all the fields for the standing candidates.
    my @field_list =
      map {
        $_->code => {
            type  => 'PosInteger',
            label => sprintf( '%s (%s)', $_->name, $_->party->name ),
            default => ( $_->votes || 0 ),
            required => 1,
            required_message =>
              'Please enter number of votes (can be "0" if no votes cast)',
          }
      } @candidates;

    # create a form
    my $form = YourNextMP::Form->new(
        name       => 'record_vates',
        field_list => \@field_list,
    );

    $c->stash->{form} = $form;

    # process the form and return if there were errors
    return if !$form->process( params => $c->req->params );

    # Form is good - let's update the candidates
    my $highest_vote = 0;
    foreach my $can (@candidates) {
        my $votes = $form->field( $can->code )->value;
        $can->update( { votes => $votes, is_winner => 0 } );
        $highest_vote = $votes if $highest_vote < $votes;
    }

    # FIXME - should be done in model
    # flag the winner (if there is only one and all votes were not zero)
    my @winners = grep { $_->votes == $highest_vote } @candidates;
    if ( $highest_vote > 0 && scalar(@winners) == 1 ) {
        $winners[0]->update( { is_winner => 1 } );
    }

    # now set the votes_recorded flag on the seat
    $seat->update(
        {
            votes_recorded      => 1,              #
            votes_recorded_when => DateTime->now
        }
    );

    # all done - return to the seat
    $c->res->redirect( $c->uri_for( $seat->path ) );
    $c->detach;
}

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
