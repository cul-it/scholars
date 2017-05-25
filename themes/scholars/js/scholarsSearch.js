/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var setSearchFeatures = {
	
	onLoad: function() {
		this.bindEventListeners();
	},
	
	bindEventListeners: function() {
		if ( $('#search-button') == null ) {
			var button = document.getElementById('search-button');
			var container = document.getElementById('search-container');
			var search = document.getElementById('show-search');
			
			button.onclick=function(){
				if ( container.offsetWidth === 0 && container.offsetHeight === 0 ) {
					container.style.display = "block";
					search.className = "fa fa-times";
					button.blur();
				}
				else {
					container.style.display = "none";
					search.className = "fa fa-search";
					button.blur();
				}
				
			}
		}
		else {
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
	
		} 
	}

};
$(document).ready(function() {
    setSearchFeatures.onLoad();
});