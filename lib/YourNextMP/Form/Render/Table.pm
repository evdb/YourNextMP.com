package YourNextMP::Form::Render::Table;

use strict;
use warnings;

use Moose::Role;

with 'HTML::FormHandler::Render::Simple' => { excludes =>
      [ 'render', 'render_field_struct', 'render_end', 'render_start' ] };

sub render {
    my $self = shift;

    my $output = $self->render_start;
    foreach my $field ( $self->sorted_fields ) {
        $output .= $self->render_field($field);
    }
    $output .= $self->render_end;
    return $output;
}

sub render_start {
    my $self   = shift;
    my $output = '<form ';
    $output .= 'action="' . $self->action . '" '      if $self->action;
    $output .= 'id="' . $self->name . '" '            if $self->name;
    $output .= 'name="' . $self->name . '" '          if $self->name;
    $output .= 'method="' . $self->http_method . '" ' if $self->http_method;
    $output .= 'enctype="' . $self->enctype . '" '    if $self->enctype;
    $output .= '>' . "\n";
    $output .= "<table>\n";
    return $output;
}

sub render_field_struct {
    my ( $self, $field, $rendered_field, $class ) = @_;

    if ( $field->type eq 'Hidden' ) {
        return $rendered_field;
    }

    my $output = qq{\n  <tr$class>\n};

    my $l_type = $self->get_label_type( $field->widget )
      || '';

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

    if ( $l_type ne 'legend' ) {
        $output .= "\n    </td>\n";
    }

    my @errors = $field->all_errors;
    $output .= "    <td class='error_column'>\n";
    $output .= qq{      <span class="error_message">$_</span><br />\n}
      for @errors;
    $output .= "    </td>\n";

    $output .= "  </tr>\n";

    return $output;
}

sub render_end {
    my $self = shift;
    my $output .= "</table>\n";
    $output .= "</form>\n";
    return $output;
}

use namespace::autoclean;

1;
