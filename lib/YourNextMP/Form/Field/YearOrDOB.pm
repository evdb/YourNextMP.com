package YourNextMP::Form::Field::YearOrDOB;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use DateTime;

apply(
    [
        {
            transform => sub {
                my $dob = $_[0];
                s{\D+}{/};
                return $dob;
            },
        },
        {
            check => sub {
                my $dob = $_[0];
                return $dob =~ m{ \A \d{4} \z }xms
                  || $dob   =~ m{ \A \d{1,2} / \d{1,2} / \d{4} \z }xms;
            },
            message => ["Bad date - should be either 'YYYY' or 'DD/MM/YYYY'"]
        },
        {
            check => sub {
                my $dob = $_[0];
                return 1 if $dob !~ m{/};

                my ( $dd, $mm, $yyyy ) = split m{/}, $dob;
                return 1
                  if eval {
                          DateTime->new(
                              year  => $yyyy,
                              month => $mm,
                              day   => $dd
                          );
                  };
                return;
            },
            message => ["This is a non-existant day - please check it"]
        },
    ]
);

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;

1;
