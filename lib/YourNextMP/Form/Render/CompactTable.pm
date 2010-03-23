package YourNextMP::Form::Render::CompactTable;

use strict;
use warnings;

use Moose::Role;

with 'YourNextMP::Form::Render::Table' => {    #
    excludes => [ 'render_field_struct', ]
};

sub render_field_struct {
    my ( $self, $field, $rendered_field, $class ) = @_;

    if ( $field->type eq 'Hidden' ) {
        return $rendered_field;
    }

    my $output = qq{\n  <tr$class>\n};

    my $l_type = $self->get_label_type( $field->widget );
    $l_type ||= 'label' if $field->type eq 'Upload';
    $l_type ||= '';

    if ( $l_type eq 'label' ) {
        $output .= '    '    #
          . '<td class="label_column">'    #
          . $self->_label($field)          #
          . "</td>\n";
    }
    elsif ( $l_type eq 'legend' ) {
        $output .= '    '                  #
          . '<td class="label_column">'
          . $self->_label($field)
          . "</td>\n</tr>\n";
    }
    else {
        $output .= "    <td class='label_column'>&nbsp;</td>\n";
    }

    if ( $l_type ne 'legend' ) {
        $output .= "    <td class='input_column'>\n";
    }

    $output .= '      ' . $rendered_field;

    my @errors = $field->all_errors;
    if (@errors) {
        $output .= qq{      <span class="error_message">$_</span><br />\n}
          for @errors;
    }

    if ( $l_type ne 'legend' ) {
        $output .= "\n    </td>\n";
    }
    $output .= "  </tr>\n";

    return $output;
}

use namespace::autoclean;

1;

