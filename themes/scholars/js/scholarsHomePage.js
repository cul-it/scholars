/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function() {
	$.fn.inView = function(){
	    //Window Object
	    var win = $(window);
	    //Object to Check
	    obj = $(this);
	    //the top Scroll Position in the page
	    var scrollPosition = win.scrollTop();
	    //the end of the visible area in the page, starting from the scroll position
	    var visibleArea = win.scrollTop() + win.height();
	    //the end of the object to check
	    var objEndPos = (obj.offset().top + obj.outerHeight());
	    return(visibleArea >= objEndPos && scrollPosition <= objEndPos ? true : false)
	};

	$('#home #home-layer').css('height',(parseInt(jQuery(window).height())) +'px');

			$(window).resize(function() {
				if($('.fixed').length < 1){
					$('#home #home-layer').css('height',(parseInt(jQuery(window).height())) +'px');
				}
			});

	var $home_layer = $('#home-layer');
	var $page_layer = $('.page');


	if($page_layer.attr('id') == 'home'){
		

		$(window).scroll(function(){
			
			/* if (!$("#logo-container").inView()) {
				$('#nav-logo').show('fade');
			}
			else {
				$('#nav-logo').hide('fade');
			} */

			// sticky nav
			var window_height,scroll_top;
				window_height = $(window).height();
				scroll_top = $(window).scrollTop();

			var $nav_bar = $('#nav-bar');
			var $dev_bar = $('#developerPanel');
			var $welcome = $('#welcome');
			var ratio = (((scroll_top * 100) / window_height) / 100) / 1.3;

			if(ratio <= 1){
				$home_layer.css({
			//		'background': 'rgba(255,255,255,' + ratio + ')'
				});
			};
			
			if ((window_height - ($nav_bar.height() + 160)) <= scroll_top) {
				$('#logo-container').fadeOut(100);
			}
			else {
				$('#logo-container').show('fade');
			}

			if((window_height - ($nav_bar.height() + 85)) <= scroll_top){
				
				if(!$nav_bar.hasClass('fixed')){
					$nav_bar.addClass('fixed');
					$dev_bar.addClass('devPanelFixed');
					$('#nav-logo').show('fade');
					$welcome.hide();

				};
			} else {
				if($nav_bar.hasClass('fixed')){
					if($page_layer.attr('id') == 'home'){

						var other_pages = $('#body');
						if(other_pages.length < 2 && $('.mobile-tablet').length < 1) {
							$nav_bar.removeClass('fixed');
							$dev_bar.removeClass('devPanelFixed');
							$('#nav-logo').hide('fade');
							$welcome.show();

						} else {
							$('#home #home-layer').css('height','auto');
						}

					} else {

					};

				};
			};			

		});

	};
	

});
