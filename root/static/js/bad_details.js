function open_in_iframe ( url ) {
    $('iframe').attr({ "src" : url });
}

$( function () {
    
    var submit_button_changed = false;
    var toggle_to_save_mode = function () {

        /*if ( !submit_button_changed ) { 
            $('input[type=submit]')
                .removeClass('skip_state')
                .val('Save!');
            submit_button_changed = true;
        }*/
            
        $(this)
            .siblings('label')
            .animate({ opacity: 0.1 });
    };
    
    $('input[type=text], textarea')
        .one('focus',    toggle_to_save_mode )
        .one('keypress', toggle_to_save_mode )
       .one('change',   toggle_to_save_mode );
        

        // <button type="button" onclick="unhide_secondary_fields(this)">
        //     Show more fields for more points
        // </button>

    $('.secondary').each(function() {
       
        var button = $('<button type="button" class="show_more"/>');
        button.html('Found other contact details? Click here to add them all');
        button.click( function () {
            $('div.secondary').slideDown();
            button.hide();
        });        

       $('.fields').append( button );
       
       return false; // only do this once
    });




} );

