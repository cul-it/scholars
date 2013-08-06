/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){
    
    $.extend(this, urlsBase);
    $.extend(this, facultyMemberCount);

    // this will ensure that the hidden classgroup input is cleared if the back button is used
    // to return to th ehome page from the search results
    $('input[name="classgroup"]').val("");    

    getFacultyMembers();  
    buildResearchFacilities();   

    if ( $('section#home-geo-focus').length == 0 ) {
        $('section#home-stats').css("display","inline-block").css("margin-top","20px");
    } 
        
    function getFacultyMembers() {
        var individualList = "";
        if ( facultyMemberCount > 0 ) {        
            // determine the row at which to start the solr query
            var rowStart = Math.floor((Math.random()*facultyMemberCount)+1)-1;
            var diff;
            var pageSize = 4; // the number of faculty to display on the home page
            var retryCount = 0;
            // in case the random number is equal to or within 3 of the facultyMemberCount 
            if ( (rowStart + (pageSize-1)) > facultyMemberCount ) {
                diff = (rowStart + (pageSize-1)) - facultyMemberCount;
                if ( diff == 0 ) {
                    rowStart = rowStart - (pageSize-1);
                }
                else {
                    rowStart = rowStart - diff;
                }
            }

            var dataServiceUrl = urlsBase + "/dataservice?getRandomSolrIndividualsByVClass=1&vclassId=";
            var url = dataServiceUrl + encodeURIComponent("http://vivo.cornell.edu/ns/mannadditions/0.1#CornellFaculty");
            url += "&page=" + rowStart + "&pageSize=" + pageSize;

            $.getJSON(url, function(results) {

                if ( results == null || results.individuals.length == 0 ) {
                    if ( retryCount < 3 ) {
                        retryCount = retryCount + 1;
                        getFacultyMembers();
                    }
                    else {
                        individualList = "<p><li>No faculty members found.</li></p>";
                        $('div#tempSpacing').hide();
                        $('div#research-faculty-mbrs ul#facultyThumbs').append(individualList);
                        $('div#research-faculty-mbrs ul#facultyThumbs').css("padding", "1.0em 0 0.825em 0.75em");
                    }
                }
                else {
                    var vclassName = results.vclass.name;
                    $.each(results.individuals, function(i, item) {
                        var individual = results.individuals[i];
                        individualList += individual.shortViewHtml;
                    });
                    $('div#tempSpacing').hide();
                    $('div#research-faculty-mbrs ul#facultyThumbs').append(individualList);
                
                    $.each($('div#research-faculty-mbrs ul#facultyThumbs li.individual'), function() {
                        if ( $(this).children('img').length == 0 ) {
                            var imgHtml = "<img width='60' alt='placeholder image' src='" + urlsBase + "/images/placeholders/person.bordered.thumbnail.jpg'>";
                            $(this).prepend(imgHtml);
                        }
                        else { 
                            $(this).children('img').load( function() {
                                adjustImageHeight($(this));
                            });
                        }
                    });
                    var viewMore = "<ul id='viewMoreFac'><li><a href='"
                                + urlsBase
                                + "/people/%23http://vivoweb.org/ontology/core%23FacultyMember' alt='view all faculty'>"
                                + "View all ...</a></li?</ul>";
                    $('div#research-faculty-mbrs').append(viewMore);
                }
            });
       }
       else {
           individualList = "<p><li>No faculty members found.</li></p>";
           $('div#tempSpacing').hide();
           $('div#research-faculty-mbrs ul#facultyThumbs').append(individualList);
           $('div#research-faculty-mbrs ul#facultyThumbs').css("padding", "1.0em 0 0.825em 0.75em");
       }
    }

    function adjustImageHeight(theImg) {
        $img = theImg;
        var hgt = $img.attr("height");
        if (  hgt > 70 ) {
            var liHtml = $img.parent('li').html();
            liHtml = liHtml.replace("<img","<div id='adjImgHeight'><img");
            liHtml = liHtml.replace("<h1","</div><h1");
            $img.parent('li').html(liHtml);
        }
    }

    function buildResearchFacilities() {
        var rfNbr = researchFacilities.length;
        var html = "<ul>";
        var index = Math.floor((Math.random()*researchFacilities.length)+1)-1;

        if ( rfNbr == 0 ) {
            html = "<ul style='list-style:none'><p><li style='padding-top:0.3em'>No research facilities found.</li></p></ul>";
        }
        else {
            for ( var i=0;i<6;i++) {
                html += "<li><a href='" + urlsBase + "/individual" 
                        + researchFacilities[index].uri + "'>" 
                        + researchFacilities[index].name + "</a></li>";
                index = Math.floor((Math.random()*researchFacilities.length)+1)-1;
            }
            html += "</ul><ul style='list-style:none'><li style='font-size:0.9em;text-align:right;padding: 6px 16px 0 0'><a href='" 
                    + urlsBase 
                    + "/organizations/%23http://vivo.library.cornell.edu/ns/0.1%23ServiceLaboratory' alt='view all research facilities'>View all ...</a></li></ul>";
        }
        $('div#research-facs').html(html);
    }
}); 
