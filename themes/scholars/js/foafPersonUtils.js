/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var foafPersonUtilities = {
	
	onLoad: function() {
		this.bindEventListeners();
	},
	
	bindEventListeners: function() {
		
		$("#manage-pubs").focus(function(event) {
			$("#manage-pubs").blur();
		});
		
		// controls the sub tab feature on the Publications tab
		$.each($("[data-type='tab-controller']"), function() {
			$selectedTab = $(this);
			$(this).click(function(event) {
				tabName = $(this).attr("id");
				$.each($("[data-type='tab-controller']"), function() {
					if ( $(this).attr("id") == tabName ) {
						$(this).removeClass("inactiveSubTab");
						$(this).addClass("activeSubTab");
					}
					else {
						$(this).addClass("inactiveSubTab");
						$(this).removeClass("activeSubTab");
					}
				});
				$.each($("[data-type='tab-contents']"), function() {
					if ( $(this).attr("id") == tabName.replace("#","") ) {
							$(this).show();
					}
					else {
						$(this).hide();
					}
				});
			});
		});
	}
};
$(document).ready(function() {
    foafPersonUtilities.onLoad();
});