package YourNextMP::View::Web;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    INCLUDE_PATH       => [ YourNextMP->path_to('templates'), ],
    TEMPLATE_EXTENSION => '.html'
);

$Template::Directive::WHILE_MAX = 10_000;

=head1 NAME

YourNextMP::View::Web - TT View for YourNextMP

=head1 DESCRIPTION

TT View for YourNextMP.

=head1 SEE ALSO

L<YourNextMP>

=head1 AUTHOR

Edmund von der Burg

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
