$(document).ready(function() {


// Graduate field pages
if ($("body").attr("id") == "fields") {
    
    // alert ("yes, it's fields");
    // Toggle Links
    $("body#fields span.toggleLink").click(function () {
        $("div.readMore").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;     
    });

    // Highlighting faculty members by research rrea
    var parameter = $.getURLParam("uri");
    var jsonLink = "data/researchAreas.jsp" + "?uri=" + parameter;

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
    
// Department pages
if ($("body").attr("id") == "departments") {
     $("body#departments span.toggleLink").click(function () {
        $("ul#moreProjects").slideToggle("medium");
        $(this).toggleClass("toggled");
        return false;
     });
}

// Faculty index Page
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

// Graduate grouping pages
if ($("body").attr("id") == "groups") {

    var parameter = $.getURLParam("uri");
    var jsonLink = "data/groupsFields2.jsp" + "?uri=" + parameter;
    // var hoverDivs = '<div id="overview"><div id="fieldDescription"></div><div id="fieldDepartments"></div></div>';
    // $("h2.groupLabel").after(hoverDivs);
    
        $.getJSON(jsonLink, function(json) {
        $("ul.fields li").mouseover(function(){
            // $(this).addClass("selected");
            var thisID = $(this).attr("class");
            $.each(json.Fields, function(i, field) {
                if (field.ID == thisID) {
                    $("div#fieldDescription").empty().append(field.Description);
                    $("div#fieldDepartments").empty().append("<ul></ul>");
                    $.each(field.Departments, function(i, dept) {
                        var newListItem = "<li>" + field.Departments[i].Label + "</li>";
                        $("div#fieldDepartments ul").append(newListItem);
                    });
                    $("div#overview").show();
                }
            });
        });
        // $("ul.fields li").mouseout(function(){
        //     $(this).removeClass("selected");
        // });
    }); 
}

}); // document ready