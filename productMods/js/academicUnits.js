/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getAcademicUnits = {
			
    onLoad: function() {

    	$.extend(this, baseUrl);
    	$.extend(this, imagesUrl);
		$('img.jump-to-top').hide();
    	this.initObjects();
    	this.initAutoComplete();
		this.bindEventListeners();
	},

	initObjects: function() {
		// part of the scrolling mechanism linked to the ajax call
		this.makeTheCall = true;
		// we need this in the js, because the html in the template gets removed
		// when we refresh the search results via the ajax call. Probably a cleaner 
		// way to do this...
		this.timeIndicator = "<li id='time-indicator'>" +
						     "<img id='time-indicator-img' src='" + imagesUrl + "/indicator1.gif'/>" +
							 "<p>Searching</p></li>";
	},
	
	scrollToSearchField: function(element) {
		var isElementVisible = getAcademicUnits.isInViewport(element, false) ;
		if ( !isElementVisible ) {
			var scrollPosition = getAcademicUnits.getPageScroll();
            var containerOffset = element.offset();
            if ( scrollPosition[1] > containerOffset.top) {
                $.scrollTo(element, 500);
            }
		}
	},

    initAutoComplete: function() {
		// autocomplete for the query text field
		$("#units-search-input").autocomplete({
			minLength: 3,
			source: function(request, response) {
  				$.ajax({
                    url: baseUrl + "/ackeywords?tokenize=true&stem=true",
                    dataType: 'json',
                    data: {
                        term: request.term,
                        type: "http://vivoweb.org/ontology/core#College,http://vivoweb.org/ontology/core#School,http://vivoweb.org/ontology/core#AcademicDepartment,http://vivoweb.org/ontology/core#Library,http://vivoweb.org/ontology/core#Institute",
						multipleTypes: true,
						querytype: "name"
					},
					complete: function(xhr, status) {
                        // Not sure why, but we need an explicit json parse here. 
                        var results = $.parseJSON(xhr.responseText);
						var terms = [];
						$.each(results, function() {
							terms.push(this.label);
						});
						console.log("terms = " + JSON.stringify(terms));
                    	response(terms);
					}
				});
			},
			select: function(event, ui) {
				console.log("ui = " + JSON.stringify(ui));
				$("#units-search-input").val(ui.item.label);
				if ( $("#discover-content").length ) {
					getAcademicUnits.scrollToSearchField($("#discover-content"));
				}
				else if ( $("#search-field-container").length ) {
					getAcademicUnits.scrollToSearchField($("#search-field-container"));
				}
			}
		});

    },

	bindEventListeners: function() {
		
		$("a#start-over-link").click(function() {
			$("#facets-and-results").empty();
			$("#results-blurb").empty();
			$("#de-search-input").val("");
			$("#de-search-input").focus();
			$(this).hide();
		});
		
		$('img.jump-to-top').click(function() {
          $("html, body").animate({ scrollTop: 0 }, 400);
        });

		$(window).on('scroll', function() {
			// if the scroll-control element exists, we have more results than the initial default number
			// so we go get the next batch
			if ( $("#scroll-control").length ) {
				var viewable = getAcademicUnits.isInViewport($("#scroll-control"), false) ;
			    if (  viewable && getAcademicUnits.makeTheCall ) {
					$("#search-indicator").show();
					getAcademicUnits.makeTheCall = false;
					var vclassId = getAcademicUnits.getVClassId();
					var queryText = getAcademicUnits.getQueryText();
					var queryType = getAcademicUnits.getQueryType();
					getAcademicUnits.getIndividuals(vclassId, queryText, queryType, "", "scrolling");
				}
			}

			// determine whether to display the "jump-to-top" image/link
			if ( !$("#discover-content").length ) {
				var posFacetsVisible = getAcademicUnits.isInViewport($("#position-facets"), true) ;
	            if ( !posFacetsVisible ) {
	                $('img.jump-to-top').show();
	            }
	            else {
	                $('img.jump-to-top').hide();
	            }
			}
		});
		// when user switches between subject and name radio, we need to init autocomplete again
		$('input[type=radio][name=querytype]').change(function() {
			$("#time-indicator").show();
			$("#units-search-querytype").val(this.value);
			$("#units-search-input").val("");
            $("form#units-search-form").submit();
	    });
	
		$("#results-search-submit").click(function() {
			$("#time-indicator").show();
		});
	
		$(".toggle-children").click(function() {
			var parent = $(this).attr("data-org");
			var state = $(this).attr("data-state");
			var $link = $(this);
			$.each($('.parent-org'), function() {
				if ( parent == $(this).attr("data-org") ) {
					if ( state == "hidden" ) {
						$(this).show();
					}
					else {
						$(this).hide();
					}
				}
			});
			if ( state == "hidden" ) {
				$link.html("");
				$link.append("<i class='fa fa-caret-up' aria-hidden='true'></i>");
				$link.attr("data-state","shown");
			}
			else {
				$link.html("");
				$link.append("<i class='fa fa-caret-down' aria-hidden='true'></i>");
				$link.attr("data-state","hidden");
			}
		});
		
/*		$('#show-all-children').mouseenter(function() {
	 			$(this).next("i").css("color","#CC6949");
	 	}).mouseleave(function() {
 			$(this).next("i").css("color","#167093");
	 	});
*/		
		$("#show-all-children").click(function() {
			var state = $(this).attr("data-state");
			var $link = $(this);
			
			if ( state == "hidden" ) {
				$link.text($link.text().replace("show","hide"));
				$link.attr("data-state","shown");
				// show all the depts and schools
				$.each($('.parent-org'), function() {
					$(this).show();
				});
				// set all the parent's carets accordingly
				$.each($('.toggle-children'), function() {
					$(this).html("");
					$(this).append("<i class='fa fa-caret-up' aria-hidden='true'></i>");
					$(this).attr("data-state","shown");
				});					
			}
			else {
				$link.text($link.text().replace("hide","show"));
				$link.attr("data-state","hidden");
				// hide all the depts and schools
				$.each($('.parent-org'), function() {
					$(this).hide();
				});
				// set all the parent's carets accordingly
				$.each($('.toggle-children'), function() {
					$(this).html("");
					$(this).append("<i class='fa fa-caret-down' aria-hidden='true'></i>");
					$(this).attr("data-state","hidden");
				});
			}
			
			// set all the parent's carets accordingly

		});
		
		$(".browse-links").click(function() {
			$("#time-indicator").show();
		   	$.each($('.active-browse-links'), function() {
		   		$(this).removeClass('active-browse-links');
		   		$(this).addClass("browse-links");
		   	});
		   	$(this).addClass("active-browse-links");
		   	$(this).removeClass("browse-links");
		   	var queryAlpha = $(this).attr("data-letter");
		   	var vclassId = getAcademicUnits.getVClassId();
		   	var queryText = getAcademicUnits.getQueryText();
		   	var queryType = getAcademicUnits.getQueryType();
		   	getAcademicUnits.getIndividuals(vclassId, queryText, queryType, queryAlpha, "alpha-search");
		});
    },

	getVClassId: function() {
		return $("#units-search-vclass").val();
	},
	
	getQueryType: function() {
		return $("#units-search-querytype").val();
	},
	
	getQueryText: function() {
		return $("#units-search-input").val();
	},
	
	// Called when a facet checkbox is clicked
    getIndividuals: function(vclassId, queryText, queryType, queryAlpha, method) {
        var url = baseUrl + "/academicUnitsJson?querytext=" + queryText + "&querytype=" + queryType + "&vclassId=" + vclassId;

		if ( queryAlpha != undefined && queryAlpha.length > 0 && method == "alpha-search") {
			url += "&queryalpha=" + queryAlpha;
		}

		if ( method == "scrolling" ) {
			var startIndex = $("#scroll-control").attr("data-start-index");
			var currentPage = $("#scroll-control").attr("data-current-page");
			url += '&currentPage=' + currentPage + "&startIndex=" + startIndex;
		}

        $.getJSON(url, function(results) {
            var individualList = "";
            // Catch exceptions when empty individuals result set is returned
            if ( results.individuals.length == 0 ) {
				$("div#results-blurb").empty();
                $("ul.searchhits").empty();
				$("div#results-container").addClass("no-results");
				$("ul.searchhits").append("<span class='no-results-found'>No results were found.</span>");
            } else {
				$("div#results-container").css("background-color","none").css("border-color","none");
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
				else {
					// remove the existing $("#scroll-control") object as it will be replaced
					$("#scroll-control").remove();
				}
				// And then add the new content, remove previous no results selector
				$("div#results-container").removeClass("no-results");
                $("ul.searchhits").append(individualList);
				// hitCount is the total number of rows found; 
				// totalCount is actually the hitsPerPage (not sure why it's named like this in the java class)
				var adjPage = (results.currentPage + 1);
				var adjStartIndex = (adjPage * results.totalCount);
				console.log("ADJ START INDEX = " + adjStartIndex);
				console.log("ADJ PAGE = " + adjPage);
				$("ul.searchhits").prepend(getAcademicUnits.timeIndicator);
				if ( results.hitCount > adjStartIndex ) {
					$("ul.searchhits").append('<li id="scroll-control" data-start-index="' + 
						adjStartIndex + '" data-current-page="' + adjPage + '"><img id="search-indicator" src="'
						+ imagesUrl + '/indicatorWhite.gif"/><span>retrieving additional results</span></li>');
				}
                getAcademicUnits.makeTheCall = true;                
                // add the new content, remove previous no results selector
				$("div#results-container").removeClass("no-results");
				if ( $("#units-search-input").val().length < 1 ) {
					$(".mst-display").remove();
				}
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
    
	// used in a couple of places. returns boolean whether an element is visible
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
    getAcademicUnits.onLoad();
});