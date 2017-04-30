/* $This file is distributed under the terms of the license in /doc/license.txt$ */

var getDomainExperts = {
			
    onLoad: function() {

    	$.extend(this, baseUrl);
    	$.extend(this, imagesUrl);
    	this.initObjects();
    	this.initAutoComplete();
		this.bindEventListeners();
		//
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
                alert("aint got nuttin");
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
				console.log("ADJ START INDEX = " + adjStartIndex);
				console.log("ADJ PAGE = " + adjPage);
				if ( results.hitCount > adjStartIndex ) {
					$("ul.searchhits").append('<li id="scroll-control" data-start-index="' + 
						adjStartIndex + '" data-current-page="' + adjPage + '" style="text-align:center"><img id="search-indicator" src="'
						+ imagesUrl + '/indicatorWhite.gif" style="display:none;vertical-align:middle"/><span style="font-size:14px;color:#95908d">retrieving additional results</span></li>');
				}

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