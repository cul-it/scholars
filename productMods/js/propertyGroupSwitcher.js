$(document).ready(function() {
if ( $("ul#profileCats").length ) {
    
    // note: parameters passed to these functions should NOT include a pound sign
    // fragments inserted into the url have "_tab" appended because IE tries to navigate to that ID even when returning false
    
    function changeUrlFragment(targetGroup) {
        document.location.hash = "#" + targetGroup + "_tab";
    }
    
    function switchPropertyGroup(targetGroup) {
        $("ul#profileCats li.currentCat").removeClass("currentCat");
        $("ul#profileCats li a").removeAttr("id").each(function(){
            var thisID = $(this).attr("href");
            if (thisID == ("#" + targetGroup)) { 
                $(this).attr("id", "currentCat");
                $(this).parent().addClass("currentCat")
             }
            $(thisID).hide();
        });
        $("#" + targetGroup).show();
        $("ul#dashboardNavigation h2").removeClass("active");
        $("ul#dashboardNavigation ul.active").removeClass("active");
        $("ul#dashboardNavigation li." + targetGroup + " h2").addClass("active"); 
        $("ul#dashboardNavigation li." + targetGroup + " ul").addClass("active"); 
    }
    
    function switchDashboardGroup(targetGroup, method) {
        $("ul#dashboardNavigation ul").each(function(){
            if (method == "quick") {
                $(this).hide();
                if ($(this).parent().hasClass(targetGroup)) { $(this).show(); }
            }
            if (method == "slide") {
                $(this).slideUp("medium");
                if ($(this).parent().hasClass(targetGroup)) { $(this).slideDown("slow"); };
            }
        });
    }
        
    // the parameter for this does need a pound sign
    function changeHighlight(property) {
        if (property != null) {
            removeHighlighting();
            bgColor = "#fffbcc";
            borderColor = "#ede9be";
            $(property).animate({ 
                borderBottomColor: borderColor,
                borderTopColor: borderColor,
                borderLeftColor: borderColor,
                borderRightColor: borderColor,
                backgroundColor: bgColor
                }, 800);
            $(property).addClass("highlighted");
        }
    }
    
    function removeHighlighting(){
        $("#content div.highlighted").css({ borderColor:"#fff", backgroundColor:"#fff" }).removeClass("highlighted");
        $("ul.dashboardCategories a.highlighted").removeClass("highlighted");
    }
    
    function scrollToHighlight(property){
        // Note: we're doing all this extra stuff because initial values for height and offset are wrong
        // since they are calculated before all the property groups are hidden.
        var targetOffset = $(property).offset({scroll: false}).top; // top of the div we want to highlight
        var offsetFromParent = targetOffset - $(property).parent().offset({scroll: false}).top; // how far it is down from its parent div
        var firstGroupOffset = $("div.propsCategory:first").offset({scroll: false}).top; // how far the very first property group is from the beginning of the document
        targetOffset = firstGroupOffset + offsetFromParent; // where we'll scroll to (with property groups hidden)
        var divHeight = $(property).height(); // total height of what we want to highglight
        var viewportHeight = getViewportHeight();
        var scrollPosition = getScrollPosition(); 
        
        // alert("Property:" + property 
        //     + "\nTarget Top: " + targetOffset 
        //     + "\nOffset from Parent: " + offsetFromParent 
        //     + "\nFirst Group: " + firstGroupOffset 
        //     + "\nDiv Height: " + divHeight 
        //     + "\nViewport: " + viewportHeight 
        //     + "\nScroll Position: " + scrollPosition);
        // $('html,body').animate({scrollTop: targetOffset - (viewportHeight/2)}, 700); 
        
        // if the div for property to be highlighted is outside of the viewport
        if (targetOffset < scrollPosition || (targetOffset + divHeight) > (viewportHeight + scrollPosition - 40)){  
            // if it's a big div, fill most of the viewport with it
            if(divHeight >=  viewportHeight*.6) {   
                $('html,body').animate({scrollTop: targetOffset - 40}, 1000); 
            }
            // if it's a little div, scroll so that it's top is about one third from the top of the viewport
            if(divHeight < viewportHeight*.6) { 
                $('html,body').animate({scrollTop: targetOffset - (viewportHeight/3)}, 1000);
            }
        }
        changeHighlight(property);
    }
    
    function getScrollPosition() {
       var height = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
       return height ? height : 0;
    }
    
    function getViewportHeight() {
        if (typeof window.innerHeight != 'undefined'){
            viewportheight = window.innerHeight
        }
        else if (typeof document.documentElement != 'undefined' 
                && typeof document.documentElement.clientHeight != 'undefined' 
                && document.documentElement.clientHeight != 0) {
            viewportheight = document.documentElement.clientHeight
        }
       return viewportheight;
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
            scrollToHighlight(propertyID);
            initialGroup = paramGroupID;
        }
    
        // if there's a fragment identifier present, switch to that group
        // fragment should have "_tab" on the end
        if ( fragment.indexOf("_") > 1 ) {
            var fragmentID = fragment.substring(1,fragment.indexOf("_")); 
            initialGroup = fragmentID;
        }
    
        switchPropertyGroup(initialGroup);
        switchDashboardGroup(initialGroup, "quick");


    
    // click handlers
    
        $("ul#profileCats li a").click(function(){
            var thisGroupID = $(this).attr("href").substring(1);
            switchPropertyGroup(thisGroupID);
            switchDashboardGroup(thisGroupID, "slide");
            changeUrlFragment(thisGroupID);
            removeHighlighting();
            $(this).blur();
            return false;
        });
        
        $("ul.dashboardCategories li a").click(function(){
            if($(this).hasClass("highlighted") == true){
                removeHighlighting();
                $(this).blur();
                return false;
            }
            else {
                var thisPropertyID = $(this).attr("href");
                var thisGroupID = $(thisPropertyID).parent().attr("id");
                switchPropertyGroup(thisGroupID);
                changeUrlFragment(thisGroupID);
                scrollToHighlight(thisPropertyID);
                // changeHighlight(thisPropertyID);
                $(this).addClass("highlighted");
                $(this).blur();
                return false;
            }
        });
        
        $("div.propsCategory div").not("div.propsCategory div.highlighted").click(function(){
            removeHighlighting();
        });
    
        $("ul#dashboardNavigation li h2").click(function(){
            $(this).parent().children("ul").slideToggle("fast");
            $(this).blur();
            return false;
        });
}
});
