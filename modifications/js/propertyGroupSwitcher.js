$(document).ready(function() {
    
    // note: parameters passed to these functions should NOT include a pound sign
    
    function switchPropertyGroup(targetGroup) {
        $("ul#profileCats li a").removeAttr("id").each(function(){
            var thisID = $(this).attr("href");
            if (thisID == ("#" + targetGroup)) { $(this).attr("id", "currentCat"); }
            $(thisID).hide();
        });
        $("#" + targetGroup).show();
        $("ul#dashboardNavigation h2").removeClass("active");
        $("ul#dashboardNavigation li." + targetGroup + " h2").addClass("active"); 
    }
    
    function switchDashboardGroup(targetGroup, method) {
        $("ul#dashboardNavigation ul").each(function(){
            if (method == "quick") {
                $(this).hide();
                if ($(this).parent().hasClass(targetGroup)) { $(this).show(); }
            }
            if (method == "slide") {
                $(this).slideUp("fast");
                if ($(this).parent().hasClass(targetGroup)) { $(this).slideDown(); };
            }
        });
    }
    
    function changeHighlight(property) {
        $("h4").removeClass("targeted");    
        if (property != null) {
            $(property).children("h4").addClass("targeted");
        }
    }
 
    // do the following after the page initially loads
    
        var initialGroup = $("ul#profileCats a#currentCat").attr("href").substring(1);
    
        // grab the property parameter from the URL if present using the getURLParam jQuery plugin (/js/jquery_plugins/getURLParam.js)
        var parameter = $.getURLParam("property");
        var fragment = document.location.hash;
    
        // if there's a fragment identifier present (directly after a parameter), don't use the parameter at all
        if (parameter != null && parameter.indexOf("#") > 0) {
            parameter = null;
        }
    
        // if the property parameter is present, let's show the parent grouping for the requested property and hide all others
        if ( parameter != null ) {
            var propertyID = "#" + parameter;
            var paramGroupID = $(propertyID).parent("div").attr("id");
            changeHighlight(propertyID);
            initialGroup = paramGroupID;
        }
    
        // if there's a fragment identifier present, switch to that group
        if ( fragment.indexOf("-") > 1 ) {
            var fragmentID = fragment.substring(1,fragment.indexOf("-"));
            initialGroup = fragmentID;
        }
    
        switchPropertyGroup(initialGroup);
        switchDashboardGroup(initialGroup, "quick");
    
    
    // event handlers
    
        $("ul#profileCats li a").click(function(){
            var thisGroupID = $(this).attr("href").substring(1);
            switchPropertyGroup(thisGroupID);
            switchDashboardGroup(thisGroupID, "slide");
            return false;
        });
        
        $("ul.dashboardCategories li a").click(function(){
            var thisPropertyID = $(this).attr("href");
            var thisGroupID = $(thisPropertyID).parent().attr("id");
            changeHighlight(thisPropertyID);
            switchPropertyGroup(thisGroupID);
            return false;
        });
    
        $("ul#dashboardNavigation li h2").click(function(){
            $(this).parent().children("ul").slideToggle("fast");
            return false;
        });
});
