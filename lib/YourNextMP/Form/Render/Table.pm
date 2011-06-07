package YourNextMP::Form::Render::Table;

use strict;
use warnings;

use Moose::Role;

with 'HTML::FormHandler::Render::Simple' => {    #
    -excludes => [
        'render',     'render_field_struct',
        'render_end', 'render_start',
        'render_upload',
    ]
};

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
    $output .= "<table class='form'>\n";
    return $output;
}

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

    if ( $l_type ne 'legend' ) {
        $output .= "\n    </td>\n";
    }

    $output .= "    <td class='error_column'>\n";

    $output .= sprintf '      <span class="hint">%s</span><br />', $field->hint
      if $field->can('hint') && $field->hint;

    $output .= qq{      <span class="error_message">$_</span><br />\n}
      for $field->all_errors;

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

sub render_upload {
    my ( $self, $field ) = @_;
    my $output = '<input type="file" name="';
    $output .= $field->html_name . '"';
    $output .= ' id="' . $field->id . '"';
    $output .= $self->_add_html_attributes($field);
    $output .= ' />';
    return $output;
}

use namespace::autoclean;

1;

