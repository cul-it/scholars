/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var initUtilities = {
	
	onLoad: function() {
		this.bindEventListeners();
	},
	
	bindEventListeners: function() {
		// controls the "Accordion" feature on the FAQ page
		$.each($('.panel-heading'), function() {
			var answer = $(this).next($('.panel-body'));
			$(this).on("click", function(){
				if ( $(answer).is(':visible') ) {
					$(answer).hide();
				}
				else {
					$(answer).show();
				}
			});
		});

	}

};
$(document).ready(function() {
    initUtilities.onLoad();
});