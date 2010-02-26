#!/usr/bin/perl

package Catalyst::Plugin::SessionHP;
use base qw/Class::Accessor::Fast /;

use strict;
use warnings;

use MRO::Compat;
use Catalyst::Exception ();
use Digest::SHA1 qw(sha1_hex);
use overload          ();
use Object::Signature ();
use Carp;
use Clone;

use Data::Dumper;
local $Data::Dumper::Sortkeys = 1;

our $VERSION = '0.03';

my @session_data_accessors;    # used in delete_session

BEGIN {
    __PACKAGE__->mk_accessors(
        "_session_delete_reason",
        @session_data_accessors = (

            '_session',
            '_session_source',    # where did the current session come from
            '_session_stored_data_signature',   # what is currently in the store
            '_session_id',                      # the current session id
            '_session_expiry_time',    # when the current session should expire

            '_flash',                  # the current flash hashref
            '_original_flash',         # the original flash hashref (cloned)

        )
    );
}

sub setup {
    my $c = shift;
    $c->maybe::next::method(@_);
    $c->check_session_plugin_requirements;
    $c->setup_session;
    return $c;
}

sub check_session_plugin_requirements {
    my $c = shift;

    unless ( $c->isa("Catalyst::Plugin::SessionHP::State")
        && $c->isa("Catalyst::Plugin::Session::Store") )
    {
        my $err = ( "The Session plugin requires both Session::State "
              . "and Session::Store plugins to be used as well." );

        $c->log->fatal($err);
        Catalyst::Exception->throw($err);
    }
}

# needed by C::P::S::Store::DBIC
sub _session_plugin_config {
    return shift->config->{'Plugin::Session'} ||= {};
}

sub setup_session {
    my $c    = shift;
    my $hour = 60 * 60;

    my $cfg = $c->_session_plugin_config;

    %$cfg = (
        max_lifetime => $hour * 2,
        min_lifetime => $hour * 1,

        %$cfg,
    );

    $c->maybe::next::method();
}

###########################################################################

sub finalize_headers {
    my $c = shift;
    $c->finalize_session;
    return $c->maybe::next::method(@_);
}

sub finalize_body {
    my $c = shift;

    # Have to call this now - it has the side effect of actually causing the
    # session data to be written to the database in
    # Catalyst::Plugin::Session::Store::Delegate
    $c->_clear_session_instance_data;

    return $c->maybe::next::method(@_);
}

#############################################################################

sub session {
    my $c = shift;

    return $c->_session
      || $c->_load_session           #
      || $c->_create_new_session;    #
}

sub session_expires {
    my $c = shift;
    return $c->_session_expiry_time || 0;
}

sub finalize_session {
    my $c = shift;
    $c->_save_flash_to_session;
    $c->_save_session;
    $c->maybe::next::method(@_);
}

sub _create_new_session {
    my $c = shift;

    # get new settings
    my $id          = $c->generate_session_id;
    my $expiry_time = time() + $c->_session_plugin_config->{max_lifetime};

    # create a new session
    $c->_session_source('new');
    $c->_session_id($id);
    $c->_session_expiry_time($expiry_time);
    $c->_session_stored_data_signature('');
    $c->_session( {} );

    return $c->_session();
}

my $session_hash_seed_counter = 0;

sub generate_session_id {
    my $c = shift;

    # create a string that will be hard to guess
    my $session_hash_seed = join "",
      $session_hash_seed_counter++,
      time, rand, $$, {}, overload::StrVal($c);

    # turn the random string into a hex string
    my $new_id = sha1_hex($session_hash_seed);

    return $new_id;
}

sub validate_session_id {
    my ( $c, $sid ) = @_;

    return $sid
      && $sid =~ m{ \A [a-f0-9]{40} \z }x;    # match SHA1 hexdigest
}

sub _save_session {
    my $c = shift;

    # Get the session data
    my $session_data = $c->_session;

    # if there is no session data then there is nothing to store
    return unless $session_data;

    # Check that the session either exists or has contents.
    if (
        $c->_session_source ne 'new'    # already in store
        || %$session_data               # contains something
      )
    {

        my $sid = $c->session_id;
        my $cfg = $c->_session_plugin_config;

        # check to see if the session has changed at all
        if ( Object::Signature::signature($session_data) ne
            $c->_session_stored_data_signature )
        {
            $session_data->{__created} ||= time();
            $session_data->{__updated} = time();
            $c->store_session_data( "session:$sid" => $session_data );
        }

        # check to see if the expiry should be extended
        my $current_expiry_time = $c->_session_expiry_time;
        my $current_lifetime    = $current_expiry_time - time();
        my $new_expiry_time    #
          = $current_lifetime < $cfg->{min_lifetime}
          ? time() + $cfg->{max_lifetime}
          : $current_expiry_time;

        # save the expiry if it is a new session or time has changed
        if (   $current_expiry_time != $new_expiry_time
            || $c->_session_source eq 'new' )
        {
            $c->store_session_data( "expires:$sid" => $new_expiry_time );
            $c->_session_expiry_time($new_expiry_time);
        }

    }
    else {

        # there was no session worth saving - clear it
        $c->_clear_session_instance_data;
    }
}

sub _clear_session_instance_data {
    my $c = shift;
    $c->maybe::next::method(@_);    # allow other plugins to hook in on this
    $c->$_(undef) for @session_data_accessors;
}

sub _load_session {
    my $c = shift;

    # try to retrieve a session_id from the state
    my $id = $c->session_id         #
      || return;

    # check that the id is valid
    if ( !$c->validate_session_id($id) ) {
        $c->delete_session('invalid session key');
        return;
    }

    # get the expiry time and session data
    my $expiry_time  = $c->get_session_data("expires:$id") || 0;
    my $session_data = $c->get_session_data("session:$id") || undef;

    # check that the session is good (has data and has not expired)
    if ( $session_data && $expiry_time > time() ) {

        # store all the bits retrieved
        $c->_session_source('store');
        $c->_session_id($id);
        $c->_session_expiry_time($expiry_time);
        $c->_session($session_data);
        $c->_session_stored_data_signature(
            Object::Signature::signature($session_data) );

        $c->log->debug(qq/Restored session "$id"/) if $c->debug;

    }
    else {

        # we set the session_id so that it is available to the state and store.
        $c->_session_id($id);

        # call delete session so that the state and store can clean up.
        $c->delete_session('session expired');
    }

    return $session_data;
}

sub delete_session {
    my ( $c, $msg ) = @_;

    $c->session_delete_reason($msg);

    # let others delete first
    $c->maybe::next::method($msg);

    $c->log->debug( "Deleting session"
          . ( defined($msg) ? "($msg)" : '(no reason given)' ) )
      if $c->debug;

    # delete the session data
    if ( my $sid = $c->session_id ) {
        $c->delete_session_data("${_}:${sid}") for qw/session expires flash/;
    }

    # reset the values in the context object
    # see the BEGIN block
    $c->_clear_session_instance_data;
}

sub session_delete_reason {
    my $c = shift;
    $c->_session_delete_reason(@_);
}

# sub session_expires {
#     my $c = shift;
#
#     if ( defined( my $expires = $c->_extended_session_expires ) ) {
#         return $expires;
#     } elsif ( defined( $expires = $c->_load_session_expires ) ) {
#         return $c->extend_session_expires($expires);
#     } else {
#         return 0;
#     }
# }
#
# sub extend_session_expires {
#     my ( $c, $expires ) = @_;
#     $c->_extended_session_expires( my $updated
#             = $c->calculate_extended_session_expires($expires) );
#     $c->extend_session_id( $c->session_id, $updated );
#     return $updated;
# }
#
# sub calculate_initial_session_expires {
#     my $c = shift;
#     return ( time() + $c->_session_plugin_config->{expires} );
# }
#
# sub calculate_extended_session_expires {
#     my ( $c, $prev ) = @_;
#     $c->calculate_initial_session_expires;
# }
#
# sub reset_session_expires {
#     my ( $c, $sid ) = @_;
#
#     my $exp = $c->calculate_initial_session_expires;
#     $c->_session_expires($exp);
#     $c->_extended_session_expires($exp);
#     $exp;
# }

sub session_id {
    my $c = shift;

    return
         $c->_session_id
      || $c->_session_id( $c->get_sesson_id_from_state )
      || '';
}

# sub _load_session_id {
#     my $c = shift;
#     return if $c->_tried_loading_session_id;
#     $c->_tried_loading_session_id(1);
#
#     if ( defined( my $sid = $c->get_session_id ) ) {
#         if ( $c->validate_session_id($sid) ) {
#
#             # temporarily set the inner key, so that validation will work
#             $c->_session_id($sid);
#             return $sid;
#         } else {
#             my $err = "Tried to set invalid session ID '$sid'";
#             $c->log->error($err);
#             Catalyst::Exception->throw($err);
#         }
#     }
#
#     return;
# }
#
# sub session_is_valid {
#     my $c = shift;
#
#     # force a check for expiry, but also __address, etc
#     if ( $c->_load_session ) {
#         return 1;
#     } else {
#         return;
#     }
# }
#
# sub validate_session_id {
#     my ( $c, $sid ) = @_;
#
#     $sid and $sid =~ /^[a-f\d]+$/i;
# }
#
#
#
#
# sub dump_these {
#     my $c = shift;
#
#     (   $c->maybe::next::method(),
#
#         $c->session_id
#         ? ( [ "Session ID" => $c->session_id ],
#             [ Session      => $c->session ],
#             )
#         : ()
#     );
# }
#
# sub get_session_id    { shift->maybe::next::method(@_) }
# sub set_session_id    { shift->maybe::next::method(@_) }
# sub delete_session_id { shift->maybe::next::method(@_) }
# sub extend_session_id { shift->maybe::next::method(@_) }

# Flash related subs

sub _save_flash_to_session {
    my $c = shift;

    my $current_flash = $c->_flash    #
      || return;

    my $original_flash = $c->_original_flash || {};

    # check that each existing key is different to the original one
    foreach my $key ( keys %$current_flash ) {

        # next if there was no entry before
        next if !exists $original_flash->{$key};

        # get a signature of both
        my $current_sig =
          Object::Signature::signature( \$current_flash->{$key} );
        my $original_sig =
          Object::Signature::signature( \$original_flash->{$key} );

        # if sigs are the same delete
        delete $current_flash->{$key}
          if $current_sig eq $original_sig;

    }

    if (%$current_flash) {
        my $session_data = $c->session;
        $session_data->{__flash} = $current_flash;
    }
    else {
        my $session_data = $c->_session;
        delete $session_data->{__flash} if $session_data;
    }

    # clear the flash so that we reload from session if needed
    $c->_flash(undef);
    $c->_original_flash(undef);

    return 1;
}

sub flash {
    my $c = shift;

    return
         $c->_flash
      || $c->_load_flash
      || $c->_create_new_flash;
}

sub _load_flash {
    my $c     = shift;
    my $flash = $c->session->{__flash};

    return unless $flash;

    $c->_original_flash( Clone::clone $flash);
    $c->_flash($flash);
}

sub _create_new_flash {
    my $c = shift;

    $c->_original_flash( {} );
    $c->_flash(          {} );

    return $c->_flash;
}

sub keep_flash {
    my ( $c, @keys ) = @_;
    my $original = $c->_original_flash;

    # deleting from the original flash will cause current values to be kept
    delete $original->{$_} for @keys;

    return 1;
}

sub clear_flash {
    my $c = shift;
    $c->_flash( {} );
}

###################################################################
# compatability shims

sub create_session_id_if_needed {
    return 1;

    # my $c = shift;
    # if ( my $id = $c->session_id ) {
    #     return $id;
    # }
    #
    # $c->_create_new_session;
    # return $c->session_id;
}

sub sessionid {
    my $c = shift;
    return $c->session_id;
}

sub session_is_valid {
    return 1;
}

1;
