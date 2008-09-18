// Graduate field pages
$(document).ready(function() {
if ($("body").attr("id") == "fields") {
        
    // Toggle Links
    $("body#fields span.toggleLink").click(function () {
        $("div.readMore").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;     
    });

    // Highlighting faculty members by research rrea
    // var parameter = $.getURLParam("uri");
	var parameter = $("meta[name='uri']").attr("content");
    var jsonLink = "/data/researchAreas.jsp" + "?uri=" + parameter;

    $.getJSON(jsonLink, function(json) {
        $("ul.researchAreaList li a").click(function(){
            if ($(this).hasClass("selected")) {
                $("div#researchAreas li a").removeClass("selected");
                $("div#fieldFaculty li").blur().removeClass("selected");
            }
            else {
                $("div#researchAreas li a").removeClass("selected");
                $("div#fieldFaculty li").removeClass("selected");
                $(this).blur().addClass("selected");
                var selectedID = $(this).parent().attr("id");
                $.each(json.research, function(i, area) {
                    if (area.ID == selectedID) {
                        $.each(json.research[i].Faculty, function(n, faculty) {
                            var targetFaculty = "li#" + json.research[i].Faculty[n];
                            $(targetFaculty).addClass("selected");
                        });
                    }
                });
            } 
        return false;
        });
    }); 
}
}); 


// Department pages
$(document).ready(function() {
if ($("body").attr("id") == "departments") {
    
     $("body#departments span.toggleLink").click(function () {
        $("ul#moreProjects").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;
     });
}
}); 


// Faculty index Page
$(document).ready(function() {
if ($("body").attr("id") == "faculty") {
      
     // Pagination functions
     var origCount = $("tfoot td").text();
     
     $("#indexNav").append('<a id="showAll" href="#">show all<\/a>');
     
     $("#indexNav a#showAll").click(function(){
         $("tbody").show();
         $("tfoot td").text("Total: " + origCount);
         $(this).blur();
         return false;
     });
     $("#indexNav a").not("#showAll").click(function(){
         var tbodyID = "#" + $(this).text();
         var count = $("tbody"+ tbodyID + " tr").length;
         $("tbody").not(tbodyID).hide();
         $("tbody").filter(tbodyID).show().each(function(){
             $(this).children("tr").children("td:first").css("padding-top", "12px");
         });
         $("tfoot td").empty().text("Total: " + count);
         $(this).blur();
         return false;
     });
    
    // $("td a.person").cluetip({
    //     titleAttribute: 'name', 
    //     width: '200px', 
    //     showTitle: false, 
    //     waitImage: false, 
    //     arrows: false,
    //     dropShadowSteps: 7,
    //     leftOffset: 30,
    //     topOffset: 30,
    //     ajaxCache: true
    // });

} 
});



// Graduate group pages
$(document).ready(function() {
if ($("body").attr("id") == "areas") {

		// Detecting Firefox 2 and below to eliminate flickering glitch described at: www.nabble.com/Need-help-on-jQuery.browser.version-td17052906s27240.html
		if( $.browser.mozilla  &&  $.browser.version.substr(0,3) < 1.9 ){
	        $("body").css("opacity",".9999");
	 	}

        // var parameter = $.getURLParam("uri");
		// var parameter = $("h2.groupLabel").attr("id");
		var parameter = $("meta[name='uri']").attr("content");
        var jsonLink = "/data/fieldsHoverData.jsp" + "?uri=" + parameter;
        var hoverDivs = '<div id="hoverBox"><h4></h4><div id="fieldDescription"></div><h5>Departments with faculty in this Field</h5><div id="fieldDepartments"></div></div>';
        var height = null;
        $("h2.groupLabel").after(hoverDivs);
        Nifty("#hoverBox","big all","#1c3637"); 
        
    
        function fieldHoverSwitch(targetFieldID, json) {
            $("div#hoverBox").show();
            $.each(json.Fields, function(i, field) {
                if (field.ID == targetFieldID) {
                    if(height != null) {
                        $("div#hoverBox").height(height + "px")
                        // height = $("div#hoverBox").height();
                    }
                    $("div#hoverBox h5").hide();
                    $("div#hoverBox h4").hide().empty().append(field.Label);
                    $("div#fieldDescription").hide().empty().append(field.Description);
                    $("div#fieldDepartments").hide().empty().append("<ul></ul>");
                    $.each(field.Departments, function(i, dept) {
                        var newListItem = "<li>" + field.Departments[i].Label + "</li>";
                        $("div#fieldDepartments ul").append(newListItem);
                    });
                    $("div#hoverBox").height("auto");
                    height = $("div#hoverBox").height();
                    $("div#fieldDescription, div#fieldDepartments, div#hoverBox h5, div#hoverBox h4").fadeIn("fast")
                }
            });
        }
        
        function changeSelected(targetFieldID) {
            $("ul.fields li a").removeClass("selected");
            $("ul.fields li." + targetFieldID + " a").addClass("selected");
        }
    
        $.getJSON(jsonLink, function(fieldsJSON) {
            var json = fieldsJSON;
            var fieldsCount = json.Fields.length - 1;
            var randomField = Math.floor(Math.random()*fieldsCount);
            // var initialField = json.Fields[randomField].ID;
            var initialField = json.Fields[0].ID;
            
            changeSelected(initialField);
            fieldHoverSwitch(initialField, json);

            $("ul.fields li a").hoverIntent({    
                 sensitivity: 2,
                 interval: 80,
                 over: function(){
                        var thisField = $(this).parent().attr("class");
                        fieldHoverSwitch(thisField, json);
                        changeSelected(thisField);
                        },
                 timeout: 300,
                 out: function(){}
            })
            
            // $("ul.fields li a").hover(function() {
                // var thisField = $(this).parent().attr("class");
                // changeSelected(thisField);
                // fieldHoverSwitch(thisField, json);
            // });
        });
} 
}); 

// Facilities page
$(document).ready(function() {
if ($("body").attr("id") == "facilities") {
    
    // Fragment identifiers inserted to allow 'return-to-group' when hitting back button
    
    $("h3 + ul").hide();
    initialGroup = document.location.hash.substring(5);
    if (initialGroup != "") {
        $("li#" + initialGroup + " ul").show();
        $("li#" + initialGroup + " h3:first").addClass("expanded");
    }
    // Open all the tabs when referrer is the search page
    else if (document.referrer.indexOf("search.jsp") > 0) {
        $("ul.facilityList").show();
        $("li h3:first").addClass("expanded");
    }
   
    
    // alert(document.referrer.indexOf("search.jsp"));
    
    $("h3.facilityGroup").css("cursor", "pointer").click( function(){
        $(this).parent().children("ul").slideToggle("medium");
        if ($(this).hasClass("expanded")) { 
            $(this).removeClass("expanded");
        }
        else {
            $(this).addClass("expanded");
        }
    });
    
    $("a.facilityPage").click( function(){
        groupID = $(this).parents("ul.facilityList").parent().attr("id");
        document.location.hash = "Tab-" + groupID;
        // alert(groupID);
        // return false;
    });
}
});


// Search page
$(document).ready(function() {
if ($("body").attr("id") == "seark") {
    var search_timeout = undefined;
    $("#search-form").append("<div id='resultsCount'></div>");
    
    function getResultCount(queryString){
        $.ajax({
            type: "GET",
            url: "http://localhost:8080/nutch/opensearch?hitsPerSite=0&amp;lang=en&amp;hitsPerPage=100",
            dataType: "xml",
            data: "query=" + queryString,
            success: function(xml){
                count = $("totalResults", xml).text() + " results";
                $("div#resultsCount").text(count).show();
                // document.write($("totalResults", xml).text());
            }
        });
    }
    
    
    $("#search-form-query").keyup(function(){
        if(search_timeout != undefined) {
            clearTimeout(search_timeout);
        }
        search_timeout = setTimeout(function() {
            search_timeout = undefined;
            if($("#search-form-query").val() == ""){
                $("div#resultsCount").hide();
            }
            else {
                currentText = $("#search-form-query").val();
                getResultCount(currentText);
            };
        }, 700);
    });

}
});

// Feedback form
$(document).ready(function() {
if ($("body").attr("id") == "feedback") {
    
    var captchaSrc = $("#captchaImage").attr("src");
    
    $("#captchaImage, em.notice a").click(function(){
        // This just adds a random parameter to get the image to reload - the parameter is ignored
        var randomParam = Math.floor(Math.random()*777);
        var newSrc = captchaSrc + "?reload=" + randomParam;
        $("#captchaImage").attr("src",newSrc);
        return false;
    });
    
    if ($("#feedbackForm").length){
        $("#feedbackForm").validate({
            errorElement: "span",
            errorPlacement: function(error, element) { error.insertAfter(element) },
            rules: { 
                type: "required",
                captcha: {
    				required: false,
    				remote: "forms/sessionkey.jsp"
    			}
            }, 
    		messages: {
    			captcha: "Correct code is required."	
    		}
        })
    }
}
});