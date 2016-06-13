/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function() {
	$('#search-button').click(function(event) {
		if ( $('#search-container').is(":visible") ) {
			$('#search-container').hide("fade");
			$('#show-search').removeClass("fa-times");
			$('#show-search').addClass("fa-search");
			$('#search-button').blur();
		}
		else {
			$('#search-container').show("fade");
			$('#show-search').addClass("fa-times");
			$('#show-search').removeClass("fa-search");
			setTimeout(function() {
		      $('#search-input').focus();
		    }, 200);
		}
	});

});
