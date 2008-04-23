$(document).ready(function() {
	
	/* Copyright (c) 2006 Mathias Bank (http://www.mathias-bank.de)
	 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) 
	 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
	 * 
	 * Thanks to Hinnerk Ruemenapf - http://hinnerk.ruemenapf.de/ for bug reporting and fixing.
	 */
	jQuery.extend({
	/**
	* Returns get parameters.
	*
	* If the desired param does not exist, null will be returned
	*
	* @example value = $.getURLParam("paramName");
	*/ 
	 getURLParam: function(strParamName){
		  var strReturn = "";
		  var strHref = window.location.href;
		  var bFound=false;

		  var cmpstring = strParamName + "=";
		  var cmplen = cmpstring.length;

		  if ( strHref.indexOf("?") > -1 ){
		    var strQueryString = strHref.substr(strHref.indexOf("?")+1);
		    var aQueryString = strQueryString.split("&");
		    for ( var iParam = 0; iParam < aQueryString.length; iParam++ ){
		      if (aQueryString[iParam].substr(0,cmplen)==cmpstring){
		        var aParam = aQueryString[iParam].split("=");
		        strReturn = aParam[1];
		        bFound=true;
		        break;
		      }

		    }
		  }
		  if (bFound==false) return null;
		  return strReturn;
		}
	});
	
	var parameter = $.getURLParam("returnTo");
	
	// if ( parameter != null ) {
	// 	var groupID = $("#"+parameter).parent().attr("id");
	// 	$("ul#profileCats li a").each(function(){
	// 		$(this).removeAttr("id");
	// 	});
	// 	$("ul#profileCats li a").attr("href").
	// }
	
	if ( parameter != null ) {
		var childID = "#"+parameter;
		// alert(childID);
		var targetID = $(childID).parent().attr("id");
		$("ul#profileCats li a").removeAttr("id").each(function(){
            var inactiveID = $(this).attr("href");
            $(inactiveID).hide();
			if (inactiveID == ("#" + targetID)) {
				$(this).attr("id", "currentCat");
			};
        });
        $("#" + targetID).show();
		$("ul#dashboardNavigation h2").removeClass("active");

		$(childID).children("h4").addClass("targeted");

	}
	
	// Hide all groups except currentCat when page loads
    $("ul#profileCats li a").not("a#currentCat").each(function(){
        var groupID = $(this).attr("href");
		var dashboardItem = $(this).text();
        $(groupID).hide();
		$("li." + dashboardItem + " ul").hide();	
    });


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
		// $("div.propsCategory div").removeClass("targeted");	
				
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
		// $(childID).addClass("targeted");	
		return false;
	});		
	
    $("ul#dashboardNavigation li h2").click(function(){
		$(this).parent().children("ul").slideToggle("fast");
        return false;

	});
});
