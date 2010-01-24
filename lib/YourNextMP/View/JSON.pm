package YourNextMP::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

__PACKAGE__->config(
    allow_callback => 1,
    callback_param => 'json_callback',
    expose_stash   => 'json_data',
);

=head1 NAME

YourNextMP::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<YourNextMP>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
