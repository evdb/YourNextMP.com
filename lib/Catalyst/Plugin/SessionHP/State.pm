#!/usr/bin/perl

package Catalyst::Plugin::SessionHP::State;

use strict;
use warnings;

__PACKAGE__;

__END__

=pod

=head1 NAME

Catalyst::Plugin::SessionHP::State - Base class for session state
preservation plugins.

=head1 SYNOPSIS

    package Catalyst::Plugin::SessionHP::State::MyBackend;
    use base qw/Catalyst::Plugin::SessionHP::State/;

=head1 DESCRIPTION

This class doesn't actually provide any functionality, but when the
C<Catalyst::Plugin::SessionHP> module sets up it will check to see that
C<< YourApp->isa("Catalyst::Plugin::SessionHP::State") >>.

When you write a session state plugin you should subclass this module this
reason only.

=head1 WRITING STATE PLUGINS

To write a session state plugin you usually need to extend two methods:

=over 4

=item prepare_(action|cookies|whatever)

Set C<session_id> (accessor) at B<prepare> time using data in the request.

Note that this must happen B<before> other C<prepare_action> instances, in
order to get along with L<Catalyst::Plugin::SessionHP>. Overriding
C<prepare_cookies> is probably the stablest approach.

=item finalize

Modify the response at to include the session ID if C<session_id> is defined,
using whatever scheme you use. For example, set a cookie, 

=back

=cut





