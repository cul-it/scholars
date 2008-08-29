$(document).ready(function() {
if ( $("ul#propGroupNav").length ) {
    
    // note: parameters passed to these functions should NOT include a pound sign
    // fragments inserted into the url have "_tab" appended because IE tries to navigate to that ID even when returning false
    
    function changeUrlFragment(targetGroup) {
        document.location.hash = "#" + targetGroup + "_tab";
    }
    
    function switchPropertyGroup(targetGroup, toggle) {
        // $("ul#propGroupNav li.currentCat").removeClass("currentCat");
        if(toggle == "on"){
            $("ul#propGroupNav li a").removeAttr("id").addClass("inactive").each(function(){
                var thisID = $(this).attr("href");
                $(thisID).hide();
                if (thisID == ("#" + targetGroup)) { 
                    $(this).attr("id", "currentCat").removeClass("inactive");
                    $("#" + targetGroup).show();
                 }
            });
        }
        if(toggle == "off"){
            $("ul#propGroupNav li a").removeAttr("id").removeClass("inactive").each(function(){
                var thisID = $(this).attr("href");
                $(thisID).show();
            });
        }
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
    
    // function updateAnchors(proptype) {
    //     $("a.add:not(.dataItem a.add)").each(function(){
    //         $(this).parent("div:has(ul.properties)").each(function(){
    //             var workingDiv = $(this);
    //             var toggleEdit = $(this).children("a.add");
    //             var editLinks = $(this).children("a.edit");
    //             $(toggleEdit).addClass("propEdit").text("edit").attr("title","edit this field")
    //             $(workingDiv).children("a.propEdit").bind("click", function(){
    //                 var propID = "#" + $(workingDiv).attr("id");
    //                 var link = $(workingDiv).children("a.propEdit").attr("href");
    //                 toggleEditMode(propID);
    //                 addNewButton(propID, link);
    //                 $(this).blur();
    //                 return false;
    //             });
    //         })
    //     })
    //     
    //     $("div.dataItem a.add, a.edit:not(.datatypeProperties a.edit)").each(function(){
    //         $(this).parent("div:has(div.datatypeProperties)").each(function(){
    //             var workingDiv = $(this);
    //             var toggleEdit = $(this).children("a.add");
    //             var editLinks = $(this).children("a.edit");
    //             $(toggleEdit).addClass("propEdit").text("edit").attr("title","edit this field")
    //             $(workingDiv).children("a.propEdit").bind("click", function(){
    //                 var propID = "#" + $(workingDiv).attr("id");
    //                 var link = $(workingDiv).children("a.propEdit").attr("href");
    //                 toggleEditMode(propID);
    //                 addNewButton(propID, link);
    //                 $(this).blur();
    //                 return false;
    //             });
    //         })
    //     })
    // 
    // }
    // 
    // function toggleEditMode(propID) {
    //     $(propID).children("ul.properties, div.datatypeProperties").toggleClass("editMode");
    //     if($(propID).find("ul.editMode, div.editMode").length > 0){
    //         $(propID).find("a.propEdit").text("close").css("font-weight","bold");
    //     } else {
    //         $(propID).find("a.propEdit").text("edit").css("font-weight","normal");
    //     }
    // }
    // 
    // function addNewButton(propID, link) {
    //     if($(propID).find("li.button").length < 1) {
    //         $(propID).children("ul.properties").append('<li class="button"><a class="addNewButton" href="' + link + '"><button>add new</button></a></li>');
    //     }
    // }
    

    // Hide edit buttons
    // $("head").append('<style type="text/css">    ul.properties a.edit, div.datatypeProperties a.edit { display: none }    ul.properties.editMode a.edit, div.datatypeProperties.editMode a.edit { display:inline }    li.button {display:none}    ul.editMode li.button {display:block}    </style>');
    // $("head").append('<style type="text/css"> div.editBox a.edit { display: none } </style>');
    
    // $("a.edit").hide();
    // updateAnchors();
    
    function insertWrappers() {
        $("div.propsItem").not("div:has(ul.properties), div:has(div.datatypeProperties)").each(function(){
            if($(this).find("div.editBox").length < 1){
                $(this).append("<div class='editBox'><div class='ajaxBox'></div></div>");
                $(this).addClass("empty");
            }
        });
        $("div.propsItem ul.properties, div.propsItem div.datatypeProperties").each(function(){
            if($(this).find("div.editBox").length < 1){
                $(this).wrap("<div class='editBox'></div>");
				$(this).after("<div class='ajaxBox'></div>");
            }
            $(this).removeClass("empty");
        });
    }
    
    function makeTogglers(){
        $("div.propsItem").children("a.add, a.edit").addClass("toggler");
    }

    // only accepts propsItem level containers
    function updateToggle(propertyDiv) {
        $(propertyDiv).each(function(){
	
            // 1: object property, populated
            if ($(this).hasClass("dataItem") == false && $(this).find("ul.properties").length > 0) {
				setupHandlers(this,"1");
                // $(this).append("<p>populated object</p>");
            }

			// 2: object property, empty
			else if ($(this).hasClass("dataItem") == false && $(this).find("ul.properties").length < 1) {
                // $(this).append("<p>empty object</p>");
				setupHandlers(this,"2");
            }

            // 3: data property, populated
            else if ($(this).hasClass("dataItem") == true && $(this).find("div.datatypeProperties").length > 0) {
                // $(this).append("<p>populated data</p>");	
            	// setupHandlers(this,"3");
			}

            // 4: data property, empty
            else if ($(this).hasClass("dataItem") == true && $(this).find("div.datatypeProperties").length < 1) {
                // $(this).append("<p>empty data</p>");
            	// setupHandlers(this,"4");
			}
        });
    }

	function setupHandlers(property, type) {
		if(type == 1) {
			$(property).children("a.toggler").text("edit").attr("title","edit this item").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(editbox + " div.ajaxBox");
				$(editbox).toggleClass("editMode");
				if($(editbox).hasClass("editMode")) { 
					$(this).text("close").css("font-weight","bold");
				} else {
					$(this).text("edit").css("font-weight","normal");
				}
			    if($(property).find("div.button").length < 1) {
					var link = $(property).children("a.toggler").attr("href");
		            $(editbox).append('<div class="button"><a class="addNewButton" href="' + link + '"><button>add new</button></a></div>');
		        }
				return false;
			})
		}
		if(type == 2) {
			$(property).children("a.toggler").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(property).children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
				$(editbox).toggleClass("editMode");
				if($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
					var formLink = $(this).attr("href")+" .editForm";
					$(ajaxbox).load(formLink);
				} else {
					$(this).text("add").attr("title","add relationship").css("font-weight","normal");
				}
				return false;
			})
		}
		if(type == 3) {
			$(property).children("a.toggler").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(editbox + " div.ajaxBox");
				$(editbox).toggleClass("editMode");
				if($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
				} else {
					$(this).text("edit").attr("title","edit this text").css("font-weight","normal");
				}
				return false;
			})
		}
		if(type == 4) {
			$(property).children("a.toggler").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(property).children("div.editBox");
				var ajaxbox = $(editbox + " div.ajaxBox");
				$(editbox).toggleClass("editMode");
				if($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
				} else {
					$(this).text("add").attr("title","add new entry").css("font-weight","normal");
				}
				return false;
			})
		}
	}
	
	$("head").append('<style type="text/css"> #contentwrap {background: #fff url(themes/vivo/site_icons/layout/bg_page_person.gif) no-repeat right top;} .editBox a.edit {display:none} .editBox.editMode a.edit {display:inline} .editBox div.button {display:none} .editBox.editMode div.button {display:block} .editBox div.ajaxBox {display:none} .editBox.editMode div.ajaxBox {display:block}</style>');
    
    makeTogglers();
    insertWrappers();
    updateToggle("div.propsItem");
    

    // $("ul#propGroupNav li a").click(function(){
    //     var thisGroupID = $(this).attr("href").substring(1);
    //     if($(this).attr("id") == "currentCat"){
    //         switchPropertyGroup(thisGroupID, "off")
    //     } else {
    //         switchPropertyGroup(thisGroupID, "on")
    //     }
    //     $(this).blur();
    //     return false;
    // })




    // // do the following after the page initially loads
    // 
    //     var initialGroup = $("ul#propGroupNav a#currentCat").attr("href").substring(1);
    // 
    //     // grab the property parameter from the URL if present using the getURLParam jQuery plugin (/js/jquery_plugins/getURLParam.js)
    //     var parameter = $.getURLParam("property");
    //     var fragment = document.location.hash;
    // 
    //     // if there's a fragment identifier present (directly after a parameter), don't use the parameter at all
    //     if (parameter != null && parameter.indexOf("#") > 0) {
    //         parameter = null;
    //     }
    // 
    //     // if the property parameter is present, let's show the parent grouping for the requested property and hide all others
    //     if ( parameter != null ) {
    //         var propertyID = "#" + parameter;
    //         var paramGroupID = $(propertyID).parent("div").attr("id");
    //         scrollToHighlight(propertyID);
    //         initialGroup = paramGroupID;
    //     }
    // 
    //     // if there's a fragment identifier present, switch to that group
    //     // fragment should have "_tab" on the end
    //     if ( fragment.indexOf("_") > 1 ) {
    //         var fragmentID = fragment.substring(1,fragment.indexOf("_")); 
    //         initialGroup = fragmentID;
    //     }
    // 
    //     // switchPropertyGroup(initialGroup);
    //     
    //     
    // 
    // // click handlers
    // 
    //     $("ul#propGroupNav li a").click(function(){
    //         var thisGroupID = $(this).attr("href").substring(1);
    //         switchPropertyGroup(thisGroupID);
    //         changeUrlFragment(thisGroupID);
    //         removeHighlighting();
    //         $(this).blur();
    //         return false;
    //     });
        
}
});
