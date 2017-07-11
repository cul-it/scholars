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
		
		$('#faq-toggle').on("click", function(){
			if ( $(this).text().indexOf('Expand') > -1 ) {
				$(this).text("Collapse all");
				$.each($('.faq-answer'), function() {
					$(this).show();
				});
			}
			else {
				$(this).text("Expand all");
				$.each($('.faq-answer'), function() {
					$(this).hide();
				});
			}
		});
	}

};
$(document).ready(function() {
    initUtilities.onLoad();
});