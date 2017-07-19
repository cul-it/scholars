/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getDomainExperts = {
			
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
		// this variable triggers the rebuilding of the department facet
		this.collegeFacetClicked = false;
		// we need this in the js, because the html in the template gets removed
		// when we refresh the search results via the ajax call. Probably a cleaner 
		// way to do this...
		this.timeIndicator = "<li id='time-indicator'>" +
						     "<img id='time-indicator-img' src='" + imagesUrl + "/indicator1.gif'/>" +
							 "<p>Searching</p></li>";
	},
	
    initAutoComplete: function() {
		// autocomplete when the subject radio is selected
		$(".subject-search").autocomplete({
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
				$("#de-search-input").val(ui.item.label);
				if ( $("#discover-content").length ) {
					getDomainExperts.scrollToSearchField($("#discover-content"));
				}
				else if ( $("#search-field-container").length ) {
					getDomainExperts.scrollToSearchField($("#search-field-container"));
				}
			}
		});

		// autocomplete when the name radio is selected
		$(".name-search").autocomplete({
			minLength: 3,
			source: function(request, response) {
  				$.ajax({
                    url: baseUrl + "/ackeywords?tokenize=true&stem=true",
                    dataType: 'json',
                    data: {
                        term: request.term,
                        type: "http://xmlns.com/foaf/0.1/Person",
						querytype: "name"
					},
					complete: function(xhr, status) {
                         
                        var results = $.parseJSON(xhr.responseText);
						var terms = [];
						$.each(results, function() {
							console.log(this.label);
							terms.push(this.label);
						});
                    	response(terms);
					}
				});
			},
			select: function(event, ui) {
				$("#de-search-input").val(ui.item.label);
				if ( $("#discover-content").length ) {
					getDomainExperts.scrollToSearchField($("#discover-content"));
				}
				else if ( $("#search-field-container").length ) {
					getDomainExperts.scrollToSearchField($("#search-field-container"));
				}
			}
		});

		// autocomplete for the explore research field
		// TO DO: need a separate js file for this
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
				$("#de-search-input").val(ui.item.label);
				if ( $("#discover-content").length ) {
					getDomainExperts.scrollToSearchField($("#discover-content"));
				}
				else if ( $("#search-field-container").length ) {
					getDomainExperts.scrollToSearchField($("#search-field-container"));
				}
			}
		});
    },

	scrollToSearchField: function(element) {
		var isElementVisible = getDomainExperts.isInViewport(element, false) ;
		if ( !isElementVisible ) {
			var scrollPosition = getDomainExperts.getPageScroll();
            var containerOffset = element.offset();
            if ( scrollPosition[1] > containerOffset.top) {
                $.scrollTo(element, 500);
            }
		}
	},

	bindEventListeners: function() {
		
		$("a#start-over-link").click(function() {
			$("#facets-and-results").empty();
			$("#results-blurb").empty();
			$("#de-search-input").val("");
			$("#de-search-input").focus();
			$("#sort-results").parent().hide();
			$(this).hide();
		});
		
		$('img.jump-to-top').click(function() {
          $("html, body").animate({ scrollTop: 0 }, 400);
        });

		$(window).on('scroll', function() {
			// if the scroll-control element exists, we have more results than the initial default number
			// so we go get the next batch
			if ( $("#scroll-control").length ) {
				var viewable = getDomainExperts.isInViewport($("#scroll-control"), false) ;
			    if (  viewable && getDomainExperts.makeTheCall ) {
					$("#search-indicator").show();
					getDomainExperts.makeTheCall = false;
					var vclassIds = getDomainExperts.getVClassIds();
					var queryText = getDomainExperts.getQueryText();
					var queryType = getDomainExperts.getQueryType();
					var colleges =  getDomainExperts.getColleges();
					var departments =  getDomainExperts.getDepartments();
					getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "scrolling", colleges, departments);
				}
			}
			
			// these booleans determine whether to display the "jump-to-top" image/link
			if ( !$("#discover-content").length ) {
				var posFacetsVisible = getDomainExperts.isInViewport($("#position-facets"), false) ;
				var deptFacetsVisible = getDomainExperts.isInViewport($("#department-facets"), true) ;
				var jumpCheckVisible = getDomainExperts.isInViewport($("#jump-check"), false) ;
	            if ( !posFacetsVisible && jumpCheckVisible ) {
	                $('img.jump-to-top').show();
	            }
				else if ( !posFacetsVisible && !deptFacetsVisible ){
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
			// used to rebuild department facets when a college is clicked
			if ( $(this).hasClass("college-cb") ) {
				getDomainExperts.collegeFacetClicked = true;
			}
			else {
				getDomainExperts.collegeFacetClicked = false;
			}

			// get all the info used in parameters
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
			var colleges =  getDomainExperts.getColleges();
			var departments =  getDomainExperts.getDepartments();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting", colleges, departments);

        });

		$("#sort-results").change(function() {
			$("#time-indicator").show();
			// get all the info used in parameters
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
			var colleges =  getDomainExperts.getColleges();
			var departments =  getDomainExperts.getDepartments();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting", colleges, departments);
		});

		// display time indicator when a new search is started
		$("#results-search-submit").click(function() {
			$("#time-indicator").show();
		});

		// when user switches between subject and name radio, we need to init autocomplete again
		$('input[type=radio][name=querytype]').change(function() {
	        if (this.value == 'subject') {
	            $("#de-search-input").removeClass("name-search");
	            $("#de-search-input").addClass("subject-search");
				getDomainExperts.initAutoComplete();
	        }
	        else if (this.value == 'name') {
	            $("#de-search-input").removeClass("subject-search");
	            $("#de-search-input").addClass("name-search");
				getDomainExperts.initAutoComplete();
	        }
			$("#de-search-input").val("");
			$("#de-search-input").focus();
	    });
    
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
	
	getColleges: function() {
		var colleges = "";
		
		if ( $("#college-facets input:checkbox:checked").length ) {
			colleges = "&colleges=";
			$(".college-cb:checked").each(function () {
				colleges += decodeURIComponent($(this).attr('data-college')) + ",";
			});
			colleges = colleges.replace(/,\s*$/, "");
		}
		return colleges;
	},
	
	getDepartments: function() {
		var departments = "";
		
		if ( $("#department-facets input:checkbox:checked").length ) {
			departments = "&departments=";
			$(".department-cb:checked").each(function () {
				departments += decodeURIComponent($(this).attr('data-department')) + ",";
			});
			departments = departments.replace(/,\s*$/, "");
		}
		return departments;
	},
	
	getPositions: function() {
		var positions = "";
		
		if ( $("#position-facets input:checkbox:checked").length ) {
			positions = "";
			$(".position-cb:checked").each(function () {
				positions += decodeURIComponent($(this).attr("value")) + ", ";
			});
			positions = positions.replace(/,\s*$/, "");
		}
		return positions;
	},

	getQueryType: function() {
		return $("#hidden-querytype").val();
	},
	
	getQueryText: function() {
		return $("#hidden-querytext").val();
	},
	
	getSortBy: function() {
		var sortBy = "&sortby=" + $("#sort-results").val();
		return sortBy;
	},

	// Called when a facet checkbox is clicked
    getIndividuals: function(vclassIds, queryText, queryType, method, colleges, departments, scroll) {
        var url = baseUrl + "/domainExpertJson?querytext=" + queryText + "&querytype=" + queryType + vclassIds;

		if ( $("#sort-results").length ) {
			url += getDomainExperts.getSortBy();
		}
		
        if ( typeof scroll === "undefined" ) {
            scroll = true;
        }
		if ( colleges.length > 0 ) {
			url += colleges;
		}
		if ( departments.length > 0 ) {
			url += departments;
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
				$("div#results-blurb").empty();
                $("ul.searchhits").empty();
				$("div#results-container").addClass("no-results");
				$("ul.searchhits").append("<span class='no-results-found'>No domain experts found for this criteria:</span><br/>" + getDomainExperts.noResultsFacetList());
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
					$("ul.searchhits").prepend(getDomainExperts.timeIndicator);
				}
                
				// remove the existing $("#scroll-control") object as it will be replaced
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
				var noun = (results.hitCount > 1) ? " domain experts" : " domain expert" ;
				$("div#results-blurb").append("<span>" + results.hitCount + noun + " found.</span>");
				getDomainExperts.makeTheCall = true;

				if ( getDomainExperts.collegeFacetClicked ) {
					getDomainExperts.buildDepartmentFacets(results.departmentFacets);
				}
				getDomainExperts.collegeFacetClicked = false;
            }            
        });
    },
 
   // when a college facet is clicked, rebuild department facet
	buildDepartmentFacets: function(results) {
		var array = [];	
		for(a in results){
			array.push([a,results[a]])
		}
		array.sort(function(a,b){return a[1] - b[1]});
		array.reverse();
		
		$("#department-facets").find(".panel-body").remove();
		var divString = "<div class='panel-body scholars-facet' ><label><input class='type-checkbox department-cb' data-department='";
		$.each(array, function(key, value) {
			$("#department-facets").append(divString + value[0] + "' type='checkbox'> " + value[0] + "<span> (" + value[1] + ")</span></label></div>");
		});
		
		// need to bind click event for these new checkboxes
        $(".department-cb").click(function() {
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
			var colleges =  getDomainExperts.getColleges();
			var departments =  getDomainExperts.getDepartments();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting", colleges, departments);
        });
	},

	// when a faceted search produces no results, we display a message and include all the
	// facets that were selected.
	noResultsFacetList: function() {
		var facetList = "";
		var positions = getDomainExperts.getPositions();
		var colleges = getDomainExperts.getColleges().replace("&colleges=","").replace(/,/g , ", ");
		var departments = getDomainExperts.getDepartments().replace("&departments=","").replace(/,/g , ", ");
		if ( positions.length > 0 ) {
			facetList += "<ul class='no-result-facet-list'><li>" + positions + "</li>";
		}
		if ( colleges.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + colleges + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + colleges + "</li>";
			}
		}
		if ( departments.length > 0 ) {
			if ( facetList.length > 0 ) {
				facetList += "<li>" + departments + "</li>";
			}
			else {
				facetList += "<ul class='no-result-facet-list'><li>" + departments + "</li>";
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
    getDomainExperts.onLoad();
});