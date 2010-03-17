package YourNextMP::Controller::DemocracyClub;

use strict;
use warnings;
use parent qw/Catalyst::Controller/;

use YourNextMP::Form::CandidateEditBadDetails;
use Digest::MD5 qw( md5_hex );
use LWP::Simple;

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->require_dc_user('Please log in to access this section of the site');
    return 1;
}

sub bad_details : Local {
    my ( $self, $c ) = @_;

    $c->forward('get_bad_detail');
    $c->forward('prepare_bad_detail_form');
    $c->forward('process_bad_detail_form');

    # should we show the explanation
    unless ( $c->session->{bad_details}{explanation_shown} ) {
        $c->session->{bad_details}{explanation_shown} = 1;
        $c->stash->{show_explanation} = 1;
    }

    return 1;
}

sub get_bad_detail : Private {
    my ( $self, $c ) = @_;

    # get the bad detail to work on
    my $bad_detail    #
      = $c->forward('get_existing_bad_detail')
      || $c->forward('get_new_bad_detail');

    # bail out if there are no more details to do
    if ( !$bad_detail ) {
        $c->stash->{template} = 'democracyclub/no_more_bad_details.html';
        $c->detach;
    }

    $c->stash(
        bad_detail => $bad_detail,
        candidate  => $bad_detail->candidate
    );

    # store the bad_detail id in the session
    $c->session->{bad_detail_id} = $bad_detail->id;

    return $bad_detail;
}

sub get_new_bad_detail : Private {
    my ( $self, $c ) = @_;

    # get the bad detail to work on
    return $c              #
      ->db('BadDetail')    #
      ->search( undef, { prefetch => 'candidate' } )    #
      ->grab;

}

sub get_existing_bad_detail : Private {
    my ( $self, $c ) = @_;

    my $stored_id = delete $c->session->{bad_detail_id}; # delete now, set later

    my $id = $c->req->param('bad_detail_id')             # from request
      || $stored_id                                      # from previous request
      || '';                                             # nothing found

    # check we're not being fed garbage
    $id =~ s{\D+}{}g;

    # check that we should not skip this one
    if ( $c->req->param('skip') ) {

        # redirect to ourselves with no arguments - otherwise the bad_detail_id
        # persists in the form
        $c->res->redirect( $c->uri_for('bad_details') );
        $c->detach;
    }

    # If there was no id then we can't find it
    return unless $id;

    # get the bad detail to work on
    return $c              #
      ->db('BadDetail')    #
      ->find($id);
}

sub prepare_bad_detail_form : Private {
    my ( $self, $c ) = @_;

    my $bad_detail = $c->stash->{bad_detail};

    # Get the form
    my $form =
      YourNextMP::Form::CandidateEditBadDetails->new(
        item => $bad_detail->candidate );

    # Add in the bad_detail_id
    $form->field('bad_detail_id')->value( $bad_detail->id );

    # hide all the fields apart from the detail we want
    foreach my $detail (qw( email phone fax address )) {

        my $field = $form->field($detail);

        my $existing_value_is_bad = $bad_detail    #
          ->others_for_candidate                   #
          ->search( { detail => $detail } )        #
          ->first;

        if ( $detail eq $bad_detail->detail ) {
            $field->value('');
        }
        elsif ($existing_value_is_bad) {
            $field->css_class('secondary');
            $field->value('');
        }
        else {
            $field->inactive(1);
        }
    }

    $c->stash( form => $form );

    return $form;
}

sub process_bad_detail_form : Private {
    my ( $self, $c ) = @_;
    my $bad_detail = $c->stash->{bad_detail};
    my $form       = $c->stash->{form};

    return unless $c->req->method eq 'POST';
    return unless $form->process( params => $c->req->body_parameters );

    $c->forward('bad_detail_succesfully_updated');
}

sub bad_detail_succesfully_updated : Private {
    my ( $self, $c ) = @_;

    my $bad_detail = $c->stash->{bad_detail};
    my $form       = $c->stash->{form};

    # Work out how much the user scored
    my $scores = $c->config->{democracy_club}{bad_detail_values};

    my @values_added = grep { $form->field($_)->value } keys %$scores;

    if (@values_added) {

        my $total_score = 0;
        $total_score += $scores->{$_} for @values_added;

        my $summary = sprintf "%s for %s (%s)", join( ', ', @values_added ),
          $bad_detail->candidate->name, $bad_detail->candidate->party->name;

        my $dc_args = {
            points_awarded => $total_score,
            summary        => $summary,
        };

        $c->forward( 'ping_dc', [$dc_args] );
    }

    # Form was good - redirect back to ourselves to pick up a new bad_detail to
    # process
    $c->res->redirect( $c->uri_for( '/' . $c->req->action ) );
    $c->detach;
}

sub ping_dc : Private {
    my ( $self, $c, $args ) = @_;

    # get the arguments together and apply defaults
    my $dc_args = {
        dc_user_id     => $c->user->dc_id,
        points_awarded => 0,
        summary        => '',
        task           => 'bad_details',
        %$args
    };

    # generate the sig
    my $login_secret = $c->config->{democracy_club}{login_secret}
      || die "need 'login_secret'";
    $dc_args->{sig} =
      md5_hex( $dc_args->{dc_user_id} . $dc_args->{task} . $login_secret );

    # create the URL
    my $dc_url = URI->new( $c->config->{democracy_club}{points_url} );
    $dc_url->query_form($dc_args);

    eval {

        # hit the url
        my $content = get($dc_url);

        # deal with a bad request
        if ($content) {    # decode content and save data
            $c->session->{dc_points} = JSON->new->decode($content);
        }
        else {
            warn "No content returned for request to $dc_url";
        }
    };

    warn $@ if $@;

    return 1;

}

1;
