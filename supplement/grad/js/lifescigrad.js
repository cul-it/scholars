$(document).ready(function() {


// Graduate Field pages
if ($("body").attr("id") == "fields") {
    
    // Toggle Links
    $("body#fields span.toggleLink").click(function () {
        $("div.readMore").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;     
    });

    // Highlighting Faculty Members by Research Area
    var parameter = $.getURLParam("uri");
    var jsonLink = "data/researchAreas.jsp" + "?uri=" + parameter;

    $.getJSON(jsonLink, function(json) {
        $("ul.researchAreaList li a").click(function(){
            if ($(this).hasClass("selected")) {
                $("div#researchAreas li a").removeClass("selected");
                $("div#fieldFaculty li").removeClass("selected");
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
    
// Department Pages
if ($("body").attr("id") == "departments") {
     $("body#departments span.toggleLink").click(function () {
        $("ul#moreProjects").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;
     });
}

// Faculty Index Page
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
}

}); // document ready