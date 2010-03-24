package YourNextMP::Form::SupporterAdd;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'YourNextMP::Form::Render::Table';

use Regexp::Common qw /URI/;

has_field 'name' => (
    type             => 'Text',
    label            => "Organization Name",
    required         => 1,
    required_message => 'Please enter a name',
);

my $url_check = {
    check => sub {
        my $url = shift;
        return $url =~ m{^$RE{URI}{HTTP}$};
    },
    message => "This is not a valid url - expecting 'http://example.com/'",
};

has_field 'website' => (
    type  => 'Text',
    label => "Website URL",
    apply => [$url_check],
);

has_field 'logo_url' => (
    type  => 'Text',
    label => "Logo URL",
    apply => [$url_check],
);

has_field 'summary' => (
    type  => 'TextArea',
    label => "Summary",
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Save'
);

no HTML::FormHandler::Moose;

1;
