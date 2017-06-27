/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getScholarship = {
			
    onLoad: function() {

    	$.extend(this, baseUrl);
    	$.extend(this, imagesUrl);
   		$.extend(this, startYear);
   		$.extend(this, endYear);
		$('img.jump-to-top').hide();
    	this.initObjects();
    	this.initAutoComplete();
		this.bindEventListeners();
},

	initObjects: function() {
		// part of the scrolling mechanism linked to the ajax call
		this.makeTheCall = true;
		this.selectedRadio = $("input[type=radio][name=querytype]:checked").val();
		
		// we need this in the js, because the html in the template gets removed
		// when we refresh the search results via the ajax call. Probably a cleaner 
		// way to do this...
		this.timeIndicator = "<li id='time-indicator'>" +
						     "<img id='time-indicator-img' src='" + imagesUrl + "/indicator1.gif'/>" +
							 "<p>Searching</p></li>";

		if ( $("#yearRange-facets").length && getScholarship.selectedRadio == "pubs" ) {
			this.slider = document.getElementById('slider');
			
			noUiSlider.create(slider, {
			    start: [ startYear, endYear ],
				padding: 10,
				step: 1,
				tooltips: true,
	          	format: {
	            	to: function ( value ) {
	              		return value;
	          		},
	          		from: function ( value ) {
	              		return value;
	          		}
				}, 
			    range: {
			        'min': [  startYear ],
			        'max': [ endYear ]
			    }
			});
		}

		if ( $("#yearRange-facets").length && getScholarship.selectedRadio == "grants" ) {
			this.slider = document.getElementById('slider');

			noUiSlider.create(slider, {
			    start: [ startYear ],
				padding: 10,
				step: 1,
				tooltips: true,
	          	format: {
	            	to: function ( value ) {
	              		return value;
	          		},
		          	from: function ( value ) {
		           		return value;
		       		}		
				}, 
			    range: {
			        'min': [  startYear ],
			        'max': [ endYear ]
			    }
			});
			$(".noUi-tooltip").hide();
			$(".noUi-tooltip").text("reset");
		}
	},
	
    initAutoComplete: function() {
		// autocomplete for the query text field
		$("#res-search-input").autocomplete({
			minLength: 3,
			source: function(request, response) {
  				$.ajax({
                    url: baseUrl + "/ackeywords?tokenize=true&stem=true",
                    dataType: 'json',
                    data: {
                        term: request.term,
                        type: "http://xmlns.com/foaf/0.1/Person",
						querytype: "subject"
					},
					complete: function(xhr, status) {
                        // Not sure why, but we need an explicit json parse here. 
                        var results = $.parseJSON(xhr.responseText);
						var terms = [];
						$.each(results, function() {
							terms.push(this.name);
						});
                    	response(terms);
					}
				});
			},
			select: function(event, ui) {
				$("#res-search-input").val(ui.item.label);
				if ( $("#discover-content").length ) {
					getScholarship.scrollToSearchField($("#discover-content"));
				}
				else if ( $("#search-field-container").length ) {
					getScholarship.scrollToSearchField($("#search-field-container"));
				}
			}
		});

    },

	scrollToSearchField: function(element) {
		var isElementVisible = getScholarship.isInViewport(element, false) ;
		if ( !isElementVisible ) {
			var scrollPosition = getScholarship.getPageScroll();
            var containerOffset = element.offset();
            if ( scrollPosition[1] > containerOffset.top) {
                $.scrollTo(element, 500);
            }
		}
	},

	bindEventListeners: function() {
		
		// If the altmetric badge isn't rendered, modify html to display
		// title across more columns
		$('div.altmetric-embed').on('altmetric:hide', function () {
			var sibling = $(this).parent().parent().parent().find(".col-md-9");
			$(sibling).removeClass("col-md-9");
			$(sibling).addClass("col-md-11");
			$(this).parent().parent().hide();
		});
		
		// start over link
		$("a#start-over-link").click(function() {
			$("#facets-and-results").empty();
			$("#results-blurb").empty();
			$("#research-radio-container").empty();
			$("#res-search-input").val("");
			$("#hidden-querytype").val("all");
			$("#res-search-input").focus();
			$(this).hide();
		});
		
		// arrow gets displayed to navigate to top of the page
		$('img.jump-to-top').click(function() {
          $("html, body").animate({ scrollTop: 0 }, 400);
        });

		$(window).on('scroll', function() {
			// if the scroll-control element exists, we have more results than the initial default number
			// so we go get the next batch
			if ( $("#scroll-control").length ) {
				var viewable = getScholarship.isInViewport($("#scroll-control"), false) ;
			    if (  viewable && getScholarship.makeTheCall ) {
					$("#search-indicator").show();
					getScholarship.makeTheCall = false;
					var queryText = getScholarship.getQueryText();
					var queryType = getScholarship.getQueryType();
					getScholarship.getIndividuals(queryText, queryType, "scrolling", getScholarship.selectedRadio);
				}
			}
			
			// these booleans determine whether to display the "jump-to-top" image/link
			if ( !$("#discover-content").length ) {
				var radioButtonsVisible = getScholarship.isInViewport($("#research-radio-container"), false) ;
				var jumpCheckVisible = getScholarship.isInViewport($("#jump-check"), false) ;
				if ( $("#funder-facets").length ) {
					var funderFacetVisible = getScholarship.isInViewport($("#funder-facets"), true) ;
				}
				else {
					var funderFacetVisible = false;
				}
				if ( $("#yearRange-facets").length ) {
					var yearRangeFacetVisible = getScholarship.isInViewport($("#yearRange-facets"), true) ;
				}
				else {
					var yearRangeFacetVisible = false;
				}
				if ( $("#pubvenue-facets").length ) {
					var pubvenueFacetVisible = getScholarship.isInViewport($("#pubvenue-facets"), true) ;
				}
				else {
					var pubvenueFacetVisible = false;
				}
				if ( $("#administrator-facets").length ) {
					var administratorFacetVisible = getScholarship.isInViewport($("#administrator-facets"), true) ;
				}
				else {
					var administratorFAcetVisible = false;
				}
				
	            if ( !radioButtonsVisible && jumpCheckVisible ) {
	                $('img.jump-to-top').show();
	            }
				else if ( !radioButtonsVisible && !jumpCheckVisible && !funderFacetVisible && !yearRangeFacetVisible &&  !pubvenueFacetVisible && !administratorFacetVisible ){
					$('img.jump-to-top').show();
				}
	            else {
	                $('img.jump-to-top').hide();
	            }
			}
		});

		// when check boxes are clicked, we need to fetch a fresh batch
        $(".type-checkbox").click(function() {
			$("#time-indicator").show();
			// get basic info used in parameters
            var queryText = getScholarship.getQueryText();
            var queryType = getScholarship.getQueryType();
            getScholarship.getIndividuals(queryText, queryType, "faceting", getScholarship.selectedRadio);

        });

		// when user switches among all, pubs, grants radio, we need to init autocomplete again
		$('input[type=radio][name=querytype]').change(function() {
			$("#time-indicator").show();
	        $("#hidden-querytype").val(this.value);
	        $("#res-search-input").val($("#hidden-querytext").val());
            
			var selected = this.value;
			if ( selected == "pubs" ) {
				var count = $("input#grants-radio").attr("data-count");
				$("input[name=unselectedRadio]").val("grants");
				$("input[name=radioCount]").val(count);
			}
			else if ( selected == "grants" ) {
				var count = $("input#pubs-radio").attr("data-count");
				$("input[name=unselectedRadio]").val("pubs");
				$("input[name=radioCount]").val(count);
			}
            
			$("#results-search-form").submit();
	    });
	
    	// Go button has been clicked
		$("#results-search-submit").click(function() {
			$("#results-search-form").attr("action",baseUrl + "/scholarship?origin=homepage");
			$("#hidden-querytype").val("all");
			$("#results-search-form").submit();
		}); 
		
		// Year range facet behavior
		if ( $("#yearRange-facets").length ) {
			// If active year facet used with grants, show the tooltip and reset link
			if ( getScholarship.selectedRadio == "grants" ) {
				getScholarship.slider.noUiSlider.on("slide", function(values, handle){
					$(".noUi-tooltip").show();
					$("#reset-dates").show();
				});
			}

			getScholarship.slider.noUiSlider.on("change", function(values, handle){
				$("#time-indicator").show();
				var queryText = getScholarship.getQueryText();
	            var queryType = getScholarship.getQueryType();
	            getScholarship.getIndividuals(queryText, queryType, "faceting", getScholarship.selectedRadio);
			});
		}
		
		// display time indicator when a new search is started
		$("#results-search-submit").click(function() {
			$("#time-indicator").show();
		});

		// reset link used with grants and Active Year facet
		if ( $("#reset-dates").length ) {
			$("a#reset-dates-link").click(function() {
				$("#time-indicator").show();
				$(".noUi-tooltip").hide();
				getScholarship.slider.noUiSlider.set(0);
				$(".noUi-tooltip").text("reset");
				var queryText = getScholarship.getQueryText();
	            var queryType = getScholarship.getQueryType();
				getScholarship.getIndividuals(queryText, queryType, "faceting", getScholarship.selectedRadio);
			});
		}
		
    },

	getVClassIdNames: function() {
		var vClassIds = "";
		
		if ( $("#position-facets input:checkbox:checked").length ) {
			$(".position-cb:checked").each(function () {
				vClassIds += $(this).val() + ",";
			});
			vClassIds = vClassIds.replace(/,\s*$/, "");
		}

		return vClassIds;
	},

	getVClassIds: function() {
		var vClassIds = "&vclassId=";
		
		if ( $("#position-facets input:checkbox:checked").length ) {
			$(".position-cb:checked").each(function () {
				vClassIds += decodeURIComponent($(this).attr('data-vclassid')) + ",";
			});
			vClassIds = vClassIds.replace(/,\s*$/, "");
		}
		else {
			vClassIds = "&vclassId=" + $("#de-search-vclass").val();
		}
		return vClassIds;
	},
	
	getAffiliations: function() {
		var affiliations = "";
		
		if ( $("#affiliation-facets input:checkbox:checked").length ) {
			affiliations = "&affiliations=";
			$(".affiliation-cb:checked").each(function () {
				affiliations += decodeURIComponent($(this).attr('data-affiliation')) + ",";
			});
			affiliations = affiliations.replace(/,\s*$/, "");
		}
		return affiliations;
	},
	
	getPubVenues: function() {
		var pubVenues = "";
		
		if ( $("#pubvenue-facets input:checkbox:checked").length ) {
			pubVenues = "&pubVenues=";
			$(".pubvenue-cb:checked").each(function () {
				pubVenues += decodeURIComponent($(this).attr('data-pubvenue')) + ",";
			});
			pubVenues = pubVenues.replace(/,\s*$/, "");
		}
		return pubVenues;
	},
	
	getAdministrators: function() {
		var administrators = "";
		
		if ( $("#administrator-facets input:checkbox:checked").length ) {
			administrators = "&administrators=";
			$(".administrator-cb:checked").each(function () {
				administrators += decodeURIComponent($(this).attr('data-administrator')) + ",";
			});
			administrators = administrators.replace(/,\s*$/, "");
		}
		return administrators;
	},
	
	getFunders: function() {
		var funders = "";
		
		if ( $("#funder-facets input:checkbox:checked").length ) {
			funders = "&funders=";
			$(".funder-cb:checked").each(function () {
				funders += decodeURIComponent($(this).attr('data-funder')) + ",";
			});
			funders = funders.replace(/,\s*$/, "");
		}
		return funders;
	},
	
	getStartYear: function() {
		var startYear = "";
		
		if ( $("#yearRange-facets").length ) {
			startYear = "&startYear=";
		 	yearArray = getScholarship.slider.noUiSlider.get();
			startYear += yearArray[0];
		}
		return startYear;
	},

	getEndYear: function() {
		var endYear = "";
		
		if ( $("#yearRange-facets").length ) {
			endYear = "&endYear=";
		 	yearArray = getScholarship.slider.noUiSlider.get();
			endYear += yearArray[1];
		}
		return endYear;
	},

	getActiveYear: function() {
		var activeYear = "";
		
		if ( $("#yearRange-facets").length && getScholarship.selectedRadio == "grants") {
			var text = $(".noUi-tooltip").text();
			if ( text == "reset" ) {
				activeYear = "&activeYear=reset"
			}
			else {
				activeYear = "&activeYear=" + getScholarship.slider.noUiSlider.get();
			}
		}
		return activeYear;
	},

	getQueryType: function() {
		return $("#hidden-querytype").val();
	},
	
	getQueryText: function() {
		return $("#hidden-querytext").val();
	},
	
	// Called when a facet checkbox is clicked
    getIndividuals: function(queryText, queryType, method, radio, scroll) {
        var url = baseUrl + "/scholarshipJson?querytext=" + queryText + "&querytype=" + queryType;
        if ( typeof scroll === "undefined" ) {
            scroll = true;
        }
		vclassIds = getScholarship.getVClassIds();
		url += vclassIds;

		affiliations = getScholarship.getAffiliations();
		if ( affiliations.length > 0 ) {
			url += affiliations;
		}
		if ( $("#yearRange-facets").length ) {
			if ( radio == "pubs" ) {
				start = getScholarship.getStartYear();
				url += start;
				end = getScholarship.getEndYear();
				url += end;
			}
			else {
				url += "&startYear=" + startYear;
				url += "&endYear=" + endYear;
				url += getScholarship.getActiveYear();
			}
		}
		if ( radio == "pubs" || radio == "grants") {
			vclassIds = getScholarship.getVClassIds();
			url += vclassIds;
		}
		if ( radio == "pubs" ) {
			pubVenues = getScholarship.getPubVenues();
			if ( pubVenues.length > 0 ) {
				url += pubVenues;
			}
		}
		else if ( radio == "grants" ) {
			administrators = getScholarship.getAdministrators();
			funders = getScholarship.getFunders();
			if ( administrators.length > 0 ) {
				url += administrators;
			}
			if ( funders.length > 0 ) {
				url += funders;
			}
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
	            var scrollPosition = getScholarship.getPageScroll();
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
				$("div#results-blurb").empty();
                $("ul.searchhits").empty();
				$("div#results-container").addClass("no-results");
				$("ul.searchhits").append("<span class='no-results-found'>No items found for this criteria:</span><br/>" + getScholarship.noResultsFacetList());
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
					$("ul.searchhits").prepend(getScholarship.timeIndicator);
				}
                
				// remove the exiting $("#scroll-control") object as it will be replaced
				$("#scroll-control").remove();
				
                // And then add the new content, remove previous no results selector
				$("div#results-container").removeClass("no-results");
                $("ul.searchhits").append(individualList);
				// hitCount is the total number of rows found; 
				// totalCount is actually the hitsPerPage (not sure why it's named like this in the java class)
				var adjPage = (results.currentPage + 1);
				var adjStartIndex = (adjPage * results.totalCount);
				console.log("ADJ START INDEX = " + adjStartIndex);
				console.log("ADJ PAGE = " + adjPage);
				if ( results.hitCount > adjStartIndex ) {
					$("ul.searchhits").append('<li id="scroll-control" data-start-index="' + 
						adjStartIndex + '" data-current-page="' + adjPage + '"><img id="search-indicator" src="'
						+ imagesUrl + '/indicatorWhite.gif"/><span>retrieving additional results</span></li>');
				}
				$("div#results-blurb").empty();
				var noun = (results.hitCount > 1) ? " items" : " item" ;
				$("div#results-blurb").append("<span>" + results.hitCount + noun + " found.</span>");
				getScholarship.makeTheCall = true;

				getScholarship.affiliationFacetClicked = false;
            }            
        });
    },
 

	// when a faceted search produces no results, we display a message and include all the
	// facets that were selected.
	noResultsFacetList: function() {
		var facetList = "";
		var vclassids = getScholarship.getVClassIdNames().replace("&vclassId=","").replace(/,/g , ", ");
		var affiliations = getScholarship.getAffiliations().replace("&affiliations=","").replace(/,/g , ", ");
		var administrators = getScholarship.getAdministrators().replace("&administrators=","").replace(/,/g , ", ");
		var funders = getScholarship.getFunders().replace("&funders=","").replace(/,/g , ", ");
		var pubvenues = getScholarship.getPubVenues().replace("&pubVenues=","").replace(/,/g , ", ");
		var start = getScholarship.getStartYear().replace("&startYear=","").replace(/,/g , ", ");
		var end = getScholarship.getEndYear().replace("&endYear=","").replace(/,/g , ", ");

		if (vclassids.length > 0 ) {
			if ( vclassids.indexOf("BFO_0000002") == -1 ) {
				facetList += "<ul class='no-result-facet-list'><li>" + vclassids + "</li>";
			}
		}
		if ( affiliations.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + affiliations + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + affiliations + "</li>";
			}
		}
		if ( administrators.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + administrators + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + administrators + "</li>";
			}
		}
		if ( funders.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + funders + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + funders + "</li>";
			}
		}
		if ( pubvenues.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + pubvenues + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + pubvenues + "</li>";
			}
		}
		if ( $("#yearRange-facets").length && getScholarship.selectedRadio == "grants") {
			var text = $(".noUi-tooltip").text();
			if ( facetList.length > 0 ) {
				facetList += "<li>Active year: " + text + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>Active year: " + text + "</li>";
			}
		}
		if ( getScholarship.selectedRadio == "pubs" ) {

			if ( start.length > 0 && end.length > 0 ) {
				if ( facetList.length > 0 ) {
					facetList += "<li>Date range: " + start + " to " + end + "</li>";
				}
				else {
					facetList += "<ul class='no-result-facet-list'><li>Date range: " + start + " to " + end + "</li>";
				}
			}
		}
		if ( facetList.length > 0 ) {
			facetList += "</ul>";
		}
		return facetList;
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
    getScholarship.onLoad();
});