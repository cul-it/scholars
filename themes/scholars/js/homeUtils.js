/* $This file is distributed under the terms of the license in /doc/license.txt$ */

//Finally!!! a js in this folder
//Move body background image when whe have an alert or welcome message in home page.

$(document).ready(function(){
  
  var checkFlashMessage = $('#flash-message');
  var checkWelcomeMessage = $('#welcome-msg-container');
  
  console.log(checkFlashMessage.length);
  
  if (checkFlashMessage.length) {
    $('body.home').css('background-position','center 45px, left 220px');
  }
  
  if (checkWelcomeMessage.length) {
    $('body.home.loggedIn').css('background-position','center 45px, left 150px');
  }

});