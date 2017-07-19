/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function() {
	$("#tagline").show();
	
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
			
			var footerViewable = isInViewport($(".cul-footer"), true);
			
			 if ( footerViewable ) {
				$('#by-the-numbers-text').css('position','absolute').css('bottom','22px');
				$('#researchers-count').css('position','absolute').css('bottom','132px');
				$('#articles-count').css('position','absolute').css('bottom','132px');
				$('#grants-count').css('position','absolute').css('bottom','132px');
				$('#journals-count').css('position','absolute').css('bottom','132px');
			}
			else {
				$('#by-the-numbers-text').css('position','fixed').css('bottom','80px');
				$('#researchers-count').css('position','fixed').css('bottom','190px');
				$('#articles-count').css('position','fixed').css('bottom','190px');
				$('#grants-count').css('position','fixed').css('bottom','190px');
				$('#journals-count').css('position','fixed').css('bottom','190px');
			} 

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
		//		$('#logo-container').fadeOut(100);
			}
			else {
		//		$('#logo-container').show('fade');
			}

			if((window_height - ($nav_bar.height() + 85)) <= scroll_top){
				
				if(!$nav_bar.hasClass('fixed')){
					$nav_bar.addClass('fixed');
					$dev_bar.addClass('devPanelFixed');
					$('#beta-banner').hide();
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
							$('#nav-logo').hide('fade', function(){
								$('#beta-banner').show('fade');
							});
							$welcome.show();
							

						} else {
							$('#home #home-layer').css('height','auto');
						}

					} else {

					};

				};
			};			

			var numbersViewable = isInViewport($("#by-the-numbers-backdrop"), true);
			if ( numbersViewable ) {
				$("#articles-count").show();
				$("#grants-count").show();
				$("#journals-count").show();
				$("#researchers-count").show();
				$("#by-the-numbers-text").show();
			}
			else {
				$("#articles-count").hide();
				$("#grants-count").hide();
				$("#journals-count").hide();
				$("#researchers-count").hide();
				$("#by-the-numbers-text").hide();
			}
		});

	};
	
 	$.extend(this, baseUrl);
// 	$.extend(this, _pac);
 	
 	getResearcherCount();
 	getGrantCount();
 	getArticleCount();
 	getJournalCount();

	$('#browse-units-link').click(function() {
//		_paq.push(['trackEvent', 'Search', 'Homepage', 'Browse Academic Units']);
		$('form#unit-search-form').submit();
	});
 	
 	$('#expert-search-link').mouseenter(function() {
 			$('#expert-search').show("fade");
 	}).mouseleave(function() {
 			if ( $('#de-search-input').val().length < 1 ) {
 				$('#expert-search').hide("fade");
 			}
 	});

 	$('#res-search-link').mouseenter(function() {
 			$('#research-search').show("fade");
 	}).mouseleave(function() {
 			if ( $('#res-search-input').val().length < 1 ) {
 				$('#research-search').hide("fade");
 			}
 	});

 	  $("#jgsm-link").mouseenter(function() {
 			$("#jgsm-image").addClass("partner-shadow");
 	  }).mouseleave(function() {
 			$("#jgsm-image").removeClass("partner-shadow");
 	  });
 	  $("#eng-link").mouseenter(function() {
 			$("#eng-image").addClass("partner-shadow");
 	  }).mouseleave(function() {
 			$("#eng-image").removeClass("partner-shadow");
 	  });
 	  $("#arts-link").mouseenter(function() {
 			$("#arts-image").addClass("partner-shadow");
 	  }).mouseleave(function() {
 			$("#arts-image").removeClass("partner-shadow");
 	  });

		function getResearcherCount() {

			$.ajax({
	            url: baseUrl + "/scholarsAjax?querytype=researcher",
	            dataType: "json",
	            data: {
	                action: "getHomePageDataGetters",
	            },
	            complete: function(xhr, status) {
	                var results = $.parseJSON(xhr.responseText);
	                // there will only ever be one key/value pair
	                if ( results != null ) {
	                    $('#researcher-count').text(results.count.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
	                }
	            }
	       });        

		}

		function getGrantCount() {

			$.ajax({
	            url: baseUrl + "/scholarsAjax?querytype=grant",
	            dataType: "json",
	            data: {
	                action: "getHomePageDataGetters",
	            },
	            complete: function(xhr, status) {
	                var results = $.parseJSON(xhr.responseText);
	                // there will only ever be one key/value pair
	                if ( results != null ) {
	                    $('#grant-count').text(results.count.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
	                }
	            }
	       });        

		}
		function getArticleCount() {

			$.ajax({
	            url: baseUrl + "/scholarsAjax?querytype=article",
	            dataType: "json",
	            data: {
	                action: "getHomePageDataGetters",
	            },
	            complete: function(xhr, status) {
	                var results = $.parseJSON(xhr.responseText);
	                // there will only ever be one key/value pair
	                if ( results != null ) {
	                    $('#article-count').text(results.count.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
	                }
	            }
	       });        

		}
		function getJournalCount() {

			$.ajax({
	            url: baseUrl + "/scholarsAjax?querytype=journal",
	            dataType: "json",
	            data: {
	                action: "getHomePageDataGetters",
	            },
	            complete: function(xhr, status) {
	                var results = $.parseJSON(xhr.responseText);
	                // there will only ever be one key/value pair
	                if ( results != null ) {
	                    $('#journal-count').text(results.count.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,"));
	                }
	            }
	       });        

		}

		function isInViewport(element, detectPartial) {
		    element = $(element);
		    detectPartial = (!!detectPartial); // if null or undefined, default to false

		    var viewport = $(window),
		        vpWidth = viewport.width(),
		        vpHeight = viewport.height(),
		        vpTop = viewport.scrollTop(),
		        vpBottom = vpTop + vpHeight,
		        vpLeft = viewport.scrollLeft(),
		        vpRight = vpLeft + vpWidth,

		        elementOffset = element.offset(),
		        elementTopArea = elementOffset.top+((detectPartial) ? element.height() : 0),
		        elementBottomArea = elementOffset.top+((detectPartial) ? 0 : element.height()),
		        elementLeftArea = elementOffset.left+((detectPartial) ? element.width() : 0),
		        elementRightArea = elementOffset.left+((detectPartial) ? 0 : element.width());

		       return ((elementBottomArea <= vpBottom) && (elementTopArea >= vpTop)) && ((elementRightArea <= vpRight) && (elementLeftArea >= vpLeft));
		}

	});
