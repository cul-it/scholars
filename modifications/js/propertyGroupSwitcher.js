$(document).ready(function() {
	
	// Hide all groups except currentCat when page loads
    $("ul#profileCats li a").not("a#currentCat").each(function(){
        var groupID = $(this).attr("href");
		var dashboardItem = $(this).text();
        $(groupID).hide();
		$("li." + dashboardItem + " ul").hide();	
        });
	$("li.unspecified")

	// Change active tab and view when tab is clicked
    $("ul#profileCats li a").click(function(){
        var activeID = $(this).attr("href");
		var activeDashboardItem = $(this).text();
        $("ul#profileCats li a").removeAttr("id").each(function(){
            var inactiveID = $(this).attr("href");
			var inactiveDashboardItem = $(this).text();
            $(inactiveID).hide();
            $("li." + inactiveDashboardItem + " ul").slideUp("fast");
			$("li." + inactiveDashboardItem + " h2").removeClass("active");
            });
        $(this).attr("id", "currentCat");
        $(activeID).show();
		$("li." + activeDashboardItem + " ul").slideDown("slow");
		$("li." + activeDashboardItem + " h2").addClass("active");
        return false;
	});
	
	// Change tab and view when dashboard item is clicked
	$("ul.dashboardCategories li a").click(function(){
		var childID = $(this).attr("href");
		var targetID = $(childID).parent().attr("id");
		
		$("h4").removeClass("targeted");	
				
		$("ul#profileCats li a").removeAttr("id").each(function(){
            var inactiveID = $(this).attr("href");
            $(inactiveID).hide();
			if (inactiveID == ("#" + targetID)) {
				$(this).attr("id", "currentCat");
			}
        });
        $("#" + targetID).show();
		$("ul#dashboardNavigation h2").removeClass("active");
		var currentLink = "ul li " + this;
		var groupHeading = "ul#dashboardNavigation h2 + ul li " + this;
		$(groupHeading).addClass("active");	
		
		$(childID).children("h4").addClass("targeted");	
		return false;
	});		
	
    $("ul#dashboardNavigation li h2").click(function(){
		$(this).parent().children("ul").slideToggle("fast");
        return false;

	});
});
