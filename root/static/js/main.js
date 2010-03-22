$( function () {

    // Find inputs that should be cleared on entry
    $('.autowipe').each(

        function ( index, element ) {

            var input = $(element);
            var alt = input.attr('alt');
            
            input
                .focusin(
                    function () {
                        if ( input.val() == '' || input.val() == alt )
                            input.val('').css({ color: '#000' });
                    }
                )
                .focusout(
                    function () {
                        if ( input.val() == '' || input.val() == alt )
                            input.val( alt ).css({ color: '#666' });
                    }
                );

            input.focusout();

        }
    );

});