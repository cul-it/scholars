/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){
    
    $.extend(this, urlsBase);
    $.extend(this, facultyMemberCount);
    $.extend(this, i18nStrings);
    
    // this will ensure that the hidden classgroup input is cleared if the back button is used
    // to return to th ehome page from the search results
    $('input[name="classgroup"]').val("");    

    getResercherCount();  
    buildResearchFacilities(); 

    if ( $('section#home-geo-focus').length == 0 ) {
        $('section#home-stats').css("display","inline-block").css("margin-top","20px");
    } 
        
    function getResercherCount() {
            var url = urlsBase + "/homepageNumbers?querytype=researcher"; 

            $.getJSON(url, function(results) {
            
                if ( results != null || results.individuals.length > 0 ) {
                    $('div#researcher-count > p').text(results.count);
                }
            });
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
        var facNbr = researchFacilities.length;
        var html = "<ul>";
        var index = Math.floor((Math.random()*facNbr)+1)-1;
        
        if ( facNbr == 0 ) {
            html = "<ul style='list-style:none'><p><li style='padding-top:0.3em'>"
                   + "No research facilities found.</li></p></ul>";
        }
        else if ( facNbr > 6 ) {
        	//if there are more than 6 departments, we want to choose a random subset and display
        	//and also to make sure the same department is not repeated twice
        	var indicesUsed = {};//utilizing a hash since easier
        	var indicesCount = 0;
        	while(indicesCount < 6) {
                index = Math.floor((Math.random()*facNbr)+1)-1;
                //if the index has already been used, this will be true
                var indexFound = (index in indicesUsed);
                //Check to see if this index hasn't already been employed
                if(!indexFound) {
                	//if this index hasn't already been employed then utilize it
                	 html += "<li><a href='" + urlsBase + "/individual" 
                     + researchFacilities[index].uri + "'>" 
                     + researchFacilities[index].name + "</a></li>";
                	 //add this index to the set of already used indices
                	 indicesUsed[index] = true;
                	 //keep count
                	 indicesCount++;
                }
            }
        }
        else {
            for ( var i=0;i<facNbr;i++) {
                html += "<li><a href='" + urlsBase + "/individual" 
                        + researchFacilities[i].uri + "'>" 
                        + researchFacilities[i].name + "</a></li>";
            }
        }
        if ( facNbr > 0 ) {
            html += "</ul><ul style='list-style:none'>"
                    + "<li style='font-size:0.9em;text-align:right;padding: 6px 16px 0 0'><a href='" 
                    + urlsBase 
                    + "/organizations#http://vivo.library.cornell.edu/ns/0.1%23ServiceLaboratory ' alt='" 
                    + "view all research facilities'>" 
                    + i18nStrings.viewAllString + "</a></li></ul>";
        }
        $('div#research-facs').html(html);
    }
    
}); 
