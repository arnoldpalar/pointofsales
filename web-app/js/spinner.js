function showLoader(){
    //Fade in the Spinner
    $('#loading_spinner').fadeIn(100);

    //Fade in Background
    $('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
    $('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(100); //Fade in the fade layer

    return false;
}

function showNoneFadeLoader(){
    jQuery('#loading_spinner').fadeIn(1);

    return false;
}

function hideNoneFadeLoader(){
    jQuery('#loading_spinner').fadeOut();

    return false;
}

function hideLoader(){
    jQuery('#fade , #loading_spinner').fadeOut(function() {
      jQuery('#fade').remove();
    });

    return false;
}