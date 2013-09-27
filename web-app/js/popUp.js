function splashPopUp(contentID, containerID, width, height, afterCompleteOpen, afterCompleteClose){
    var transition = 300;
    var popUpID = 'popUpContainer';

    //Fade in Background
    jQuery('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
    jQuery('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(100); //Fade in the fade layer - .css({'filter' : 'alpha(opacity=80)'}) is used to fix the IE Bug on fading transparencies

    jQuery('#fade').click(function() {
        jQuery('#' + contentID).hide();
        jQuery('#' + containerID).append(jQuery('#'+contentID));
        closeAndResetPopUpSplash(popUpID, afterCompleteClose);
    });

    jQuery('body').append('<div id=' + popUpID + ' class="popup_block"></div>');

    centralize(popUpID);

    //Fade in the Popup
    jQuery('#'+popUpID).fadeIn().animate({height:height}, {
        step:function(){
            centralizeVertical(popUpID)
        }}, transition).animate({width: width}, {
            complete:function(){
                //Load the content
                jQuery('#'+popUpID).append(jQuery('#'+contentID));
                jQuery('#'+contentID).show();

                afterCompleteOpen();
            },step:function(){
                centralizeHorizontal(popUpID)
            }}, transition);

    return false;

}

function centralize(elementID){
    //Apply Margin to Popup
    jQuery('#'+elementID).css({
        'margin-top' : -((jQuery('#'+elementID).height() + 40) / 2),
        'margin-left' : -((jQuery('#'+elementID).width() + 40) / 2)
    });
}

function centralizeHorizontal(elementID){

    jQuery('#'+elementID).css({
        'margin-left' : -(($('#'+elementID).width() + 40) / 2)
    });
}

function centralizeVertical(elementID){

    jQuery('#'+elementID).css({
        'margin-top' : -(($('#'+elementID).height() + 40) / 2)
    });
}

function closePopUpSplash(popUpID){
    jQuery('#fade, #' + popUpID).fadeOut(function() {
        jQuery('#fade').remove();
    });
    return false;
}

function closeAndResetPopUpSplash(popUpID, afterComplete){
    var transition = 300;
    jQuery('#'+popUpID).empty();

    jQuery('#'+popUpID).animate({width: "0px"}, {step:function(){
        centralizeHorizontal(popUpID);
    }}, transition).animate({height:"0px"}, {step:function(){
            centralizeVertical(popUpID);
    }, complete:function(){
            afterComplete();
    }}, transition).fadeOut();

    closePopUpSplash(popUpID);
}

function outClosePopUpSplash(popUpID, contentID, containerID, afterComplete){
    var transition = 300;
    jQuery('#' + contentID).hide();
    jQuery('#' + containerID).append(jQuery('#'+contentID));
    jQuery('#'+popUpID).empty();

    jQuery('#'+popUpID).animate({width: "0px"}, {step:function(){
        centralizeHorizontal(popUpID);
    }}, transition).animate({height:"0px"}, {step:function(){
            centralizeVertical(popUpID)
        }, complete:function(){
            afterComplete();
        }}, transition).fadeOut();

    closePopUpSplash(popUpID);
}