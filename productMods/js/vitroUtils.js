/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){

    // Use jQuery() instead of $() alias, because dwr/util.js, loaded on back end editing 
    // pages, overwrites $.
    // fade out welcome-message when user logs in
    jQuery.extend(this, i18nStrings);
    
    jQuery('section#welcome-message').css('display', 'block').delay(2000).fadeOut(1500);
    
    // fade in flash-message when user logs out
    jQuery('section#flash-message').css('display', 'none').fadeIn(1500);
    
    /////////////////////////////
     // Home search filter
     // Toggle filter select list

	/*** Removed all of the code for the vitro/vivo search field, as we do not use it ***/
	/*** in Scholars and it was generating an error on back-end editing pages.        ***/
});
