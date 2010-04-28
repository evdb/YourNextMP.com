var GB_ANIMATION = true;

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


    // change all the 'add_suggestion' links so that they show the suggestion form
    // instead of clicking through.
    $('.add_suggestion').click(
        function() {
            
            $('#suggestion_box')
                .detach()
                .insertAfter( $(this) )
                .fadeIn();

            $('#suggestion_box textarea').focus();

            return false;
        }
    );
    
});