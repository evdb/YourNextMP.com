function open_in_iframe ( url ) {
    $('iframe').attr({ "src" : url });
}

$( function () {
    
    // create the extra field links
    $('div.secondary').each(
        function ( index, element ) {
            var a     = $('<a href="#"/>');
            var li    = $('<li></li>');
            var name = $('label', element ).attr('for');

            if ( !name )
                return true ;

            a.html( name );
            a.click(function() {
                $(element).slideToggle();
                return false;
            });

            li.append( a );

            $('#extra_fields').append( li ).show();
        }
    );
        
} );
