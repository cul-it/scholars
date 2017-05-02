/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getDomainExperts = {
			
    onLoad: function() {

    	$.extend(this, baseUrl);
    	$.extend(this, imagesUrl);
    	this.initObjects();
    	this.initAutoComplete();
		this.bindEventListeners();
		var collegeFacetClicked = false;
},

	initObjects: function() {
		this.makeTheCall = true;
	},
	
    initAutoComplete: function() {
		
		$(".subject-search").autocomplete({
			minLength: 3,
			source: function(request, response) {
  				$.ajax({
                    url: baseUrl + "/ackeywords?tokenize=true&stem=true",
                    dataType: 'json',
                    data: {
                        term: request.term,
                        type: "http://xmlns.com/foaf/0.1/Person"
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
			}
		});

		$(".name-search").autocomplete({
			minLength: 3,
			source: function(request, response) {
  				$.ajax({
                    url: baseUrl + "/autocomplete?tokenize=true&stem=true",
                    dataType: 'json',
                    data: {
                        term: request.term,
                        type: "http://xmlns.com/foaf/0.1/Person"
					},
					complete: function(xhr, status) {
                        // Not sure why, but we need an explicit json parse here. 
                        var results = $.parseJSON(xhr.responseText);
						var terms = [];
						$.each(results, function() {
							terms.push(this.label.substring( 0, this.label.indexOf(" (")));
						});
                    	response(terms);
					}
				});
			},
			select: function(event, ui) {
				$("#de-search-input").val(ui.item.label);
			}
		});

    },

	bindEventListeners: function() {
		
		$("a#start-over-link").click(function() {
			$("#facets-and-results").empty();
			$("#de-search-input").val("");
			$("#de-search-input").focus();
			$(this).hide();
		});

		$(window).on('scroll', function() {
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
		});

        $(".type-checkbox").click(function() {
			// used to rebuild department facets when a college is clicked
			if ( $(this).hasClass("college-cb") ) {
				collegeFacetClicked = true;
			}
			else {
				collegeFacetClicked = false;
			}
			// get all the info used in parameters
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
			var colleges =  getDomainExperts.getColleges();
			var departments =  getDomainExperts.getDepartments();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting", colleges, departments);

        });

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
	
	// Called when a facet checkbox is clicked
    getIndividuals: function(vclassIds, queryText, queryType, method, colleges, departments, scroll) {
        var url = baseUrl + "/domainExpertJson?querytext=" + queryText + "&querytype=" + queryType + vclassIds;
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
				$("ul.searchhits").append("<span class='no-results-found'>No scholars found for this criteria:</span><br/>" + getDomainExperts.noResultsFacetList());
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
				var noun = (results.hitCount > 1) ? " scholars" : " scholar" ;
				$("div#results-blurb").append("<span>" + results.hitCount + noun + " found.</span>");
				getDomainExperts.makeTheCall = true;

				if ( collegeFacetClicked ) {
					getDomainExperts.buildDepartmentFacets(results.departmentFacets);
				}
            }            
        });
    },
    
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
        $(".departmen-cb").click(function() {
			var vclassIds =  getDomainExperts.getVClassIds();
            var queryText = getDomainExperts.getQueryText();
            var queryType = getDomainExperts.getQueryType();
			var colleges =  getDomainExperts.getColleges();
			var departments =  getDomainExperts.getDepartments();
            getDomainExperts.getIndividuals(vclassIds, queryText, queryType, "faceting", colleges, departments);
        });
	},

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