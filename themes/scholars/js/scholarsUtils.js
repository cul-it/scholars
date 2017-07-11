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
			if ( $(this).text().indexOf('expand') > -1 ) {
				$(this).text("collapse all");
				$.each($('.faq-answer'), function() {
					$(this).show();
				});
			}
			else {
				$(this).text("expand all");
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