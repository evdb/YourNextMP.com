package Catalyst::Authentication::Credential::None;
use base 'Catalyst::Authentication::Credential::Password';

use strict;
use warnings;

use Carp;
use Catalyst::Exception;

our $VERSION = '0.01';

=head1 NAME

Catalyst::Authentication::Credential::None

=head1 SYNOPSIS

    __PACKAGE__->config(

        'Plugin::Authentication' => {
            default_realm => 'your_realm',
            realms        => {
                your_realm => {
                    credential => {
                        class           => 'None',
                    },
                },
            },
        },

    );

=head1 DESCRIPTION

When your developing an app it is often convenient to be able to log in as any
user. You can either achieve this by disabling authentication (but then you
can't test failed logins) or by setting all the passwords to be the same
(which is annoying).

Or you can use this module and set one password for all users at the
authentication level. This leaves the rest of your code untouched.

=head1 HOW IT WORKS

This module is based on L<Catalyst::Authentication::Credential::Password> and
overides the C<check_password> method.


=head2 check_password

Always returns true.

=cut

sub check_password {
    my ( $self, $user, $authinfo ) = @_;

    return 1;
}

=head1 SEE ALSO

L<Catalyst::Authentication::Credential::Password>

=head1 BUGS

Test suite is minimal.

=head1 AUTHOR

Edmund von der Burg C<<evdb@ecclestoad.co.uk>>

Bug reports and suggestions very welcome.

=head1 ACKNOWLEDGMENTS

Developed whilst working at Foxtons - L<http://www.foxtons.co.uk>. Thank you
for letting me open source this code.

=head1 COPYRIGHT

Copyright (C) 2008 Edmund von der Burg. All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

THERE IS NO WARRANTY.

=cut

1;

