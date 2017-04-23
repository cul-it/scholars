/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getDomainExperts = {
			
    onLoad: function() {
    	$.extend(this, concepts);
    	$.extend(this, baseUrl);
    	this.initObjects();
    	this.initAutoComplete();
		this.bindEventListeners();
		
},

	initObjects: function() {
		this.makeTheCall = true;
	},
	
    initAutoComplete: function() {

		$( "#de-search-input" ).autocomplete({
  			minlength: 3,
  			source: concepts
		});
    },

	bindEventListeners: function() {

		$(window).on('scroll', function() {
			if ( $("#scroll-control").length ) {
				var viewable = getDomainExperts.isInViewport($("#scroll-control"), false) ;
			    if (  viewable && getDomainExperts.makeTheCall ) {
					console.log("Making The Call");
					getDomainExperts.makeTheCall = false;
					var vclassIds = getDomainExperts.getVClassIds();
					var queryText = getDomainExperts.getQueryText();
					var queryType = getDomainExperts.getQueryType();
					getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "scrolling");
				}
			}
		});

        $(".type-checkbox").click(function() {
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting");
        });
    
    },

	getVClassIds: function() {
		var vClassIds = "&vclassId=";
		
		if ( $("#facet-container input:checkbox:checked").length ) {
			$(".type-checkbox:checked").each(function () {
				vClassIds += decodeURIComponent($(this).attr('data-vclassid')) + ",";
			});
			vClassIds = vClassIds.replace(/,\s*$/, "");
		}
		else {
			vClassIds = "&vclassId=" + $("#de-search-vclass").val();
		}
		return vClassIds;
	},
	
	getQueryType: function() {
		return $("#hidden-querytype").val();
	},
	
	getQueryText: function() {
		return $("#hidden-querytext").val();
	},
	
	// Called when a facet checkbox is clicked
    getIndividuals: function(vclassIds, queryText, queryType, method, scroll) {
        var url = baseUrl + "/domainExpertJson?querytext=" + queryText + "&querytype=" + queryType + vclassIds;
        if ( typeof scroll === "undefined" ) {
            scroll = true;
        }

		if ( method == "scrolling" ) {
			var startIndex = $("#scroll-control").attr("data-start-index");
			var currentPage = $("#scroll-control").attr("data-current-page");
			url += '&currentPage=' + currentPage + "&startIndex=" + startIndex;
		}
		else {
			// if we're faceting, we need to return to the top of the results list
	        // Scroll to #nav-logo unless told otherwise
	        if ( scroll != false ) {
	            // only scroll back up if we're past the top of the #browse-by section
	            var scrollPosition = getDomainExperts.getPageScroll();
	            var containerOffset = $('#facet-container').offset();
	            if ( scrollPosition[1] > containerOffset.top) {
	                $.scrollTo('#nav-logo', 500);
	            }
	        }
		}

        $.getJSON(url, function(results) {
            var individualList = "";
            // Catch exceptions when empty individuals result set is returned
            if ( results.individuals.length == 0 ) {
                //browseByVClass.emptyResultSet(results.vclass, alpha)
            } else {
                var vclassName = results.vclass.name;
                $.each(results.individuals, function(i, item) {
                    var individual = results.individuals[i];
                    individualList += individual.shortViewHtml;
                })
                
				// if we're scrolling, we want to keep the existing content;
				// if not (i.e., a fresh search), remove the existing content.
				if ( method != "scrolling" ) {
                	$("ul.searchhits").empty();
				}
                
				// remove the exiting $("#scroll-control") object as it will be replaced
				$("#scroll-control").remove();
				
                // And then add the new content
                $("ul.searchhits").append(individualList);
				// hitCount is the total number of rows found; 
				// totalCount is actually the hitsPerPage (not sure why it's named like this in the java class)
				var adjPage = (results.currentPage + 1);
				var adjStartIndex = (adjPage * results.totalCount);
				if ( results.hitCount > adjStartIndex ) {
					$("ul.searchhits").append('<li id="scroll-control" data-start-index="' + 
						adjStartIndex + '" data-current-page="' + adjPage + '">holy toledo</li>');
				}
				console.log("URL = " + url);
				console.log("AdjStartIndex = " + adjStartIndex);
				console.log("AdjPage = " + adjPage);
				getDomainExperts.makeTheCall = true;
            }            
        });
    },
    
	// getPageScroll() by quirksmode.org
	getPageScroll: function() {
	    var xScroll, yScroll;
	    if (self.pageYOffset) {
	      yScroll = self.pageYOffset;
	      xScroll = self.pageXOffset;
	    } else if (document.documentElement && document.documentElement.scrollTop) {
	      yScroll = document.documentElement.scrollTop;
	      xScroll = document.documentElement.scrollLeft;
	    } else if (document.body) {// all other Explorers
	      yScroll = document.body.scrollTop;
	      xScroll = document.body.scrollLeft;
	    }
	    return new Array(xScroll,yScroll)
	},
    
	isInViewport: function(element, detectPartial) {
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
}; 
$(document).ready(function() {
    getDomainExperts.onLoad();
});