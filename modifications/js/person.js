tinyMCE.init({
     theme : "advanced",
     mode : "none",
     theme_advanced_buttons1 : "bold,italic,underline,separator,link,bullist,numlist,separator,sub,sup,charmap,separator,undo,redo,separator,removeformat,cleanup,help,code",
     theme_advanced_buttons2 : "",
     theme_advanced_buttons3 : "",
     theme_advanced_toolbar_location : "top",
     theme_advanced_toolbar_align : "left",
     theme_advanced_resizing : true,
     height : "2",
     width  : "99%",
     valid_elements : "a[href|target|name|title],br,p,i,em,cite,strong/b,u,ul,ol,li"     
});

$(document).ready(function() {
if ( $("ul#propGroupNav").length ) {
     
    function makeEditBoxes(propID) {
        if ( propID != null){ var targetDiv = propID; } 
        else { var targetDiv = "div.propsItem"; }
        
        $(targetDiv).not("div:has(ul.properties), div:has(div.datatypeProperties)").each(function(){
            if($(this).find("div.editBox").length < 1){
                $(this).append("<div class='editBox'><div class='ajaxBox'></div></div>");
                $(this).addClass("empty");
            }
        });
        $(targetDiv + " ul.properties, " + targetDiv + " div.datatypeProperties").each(function(){
            if($(this).find("div.editBox").length < 1){
                $(this).wrap("<div class='editBox'></div>");
				$(this).after("<div class='ajaxBox'></div>");
            }
            $(this).removeClass("empty");
        });
    }
    
    function makeTogglers(propID) {
        if ( propID != null){ var targetDiv = propID; } 
        else { var targetDiv = "div.propsItem"; }
        
        $(targetDiv).children("a.add, a.edit").addClass("toggler"); // only reaches immediate children
    }

    // accepts only propsItem level containers
    function checkPropType(propertyDiv) {
        if ( propertyDiv == null) { var propertyDiv = "div.propsItem" } 
        
        $(propertyDiv).each(function(){
	
            // 1: object property, populated
            if ($(this).hasClass("dataItem") == false && $(this).find("ul.properties").length > 0) {
				setupHandlers(this,"1");
            }

			// 2: object property, empty
			else if ($(this).hasClass("dataItem") == false && $(this).find("ul.properties").length < 1) {
                // setupHandlers(this,"2");
            }

            // 3: multi-statement data property
            else if ($(this).hasClass("multiItem") == true) {
                if ($(this).children("a.add, a.edit").length == 0) {
                    $(this).children("h4").after("<a class='image edit toggler' title='edit these items' href='#'>edit</a>");
                }
                setupHandlers(this,"3");
			}

            // 4: single-statement data property, populated
            else if ($(this).hasClass("dataItem") == true && $(this).find("div.datatypeProperties").length > 0) {
                // setupHandlers(this,"4");
			}

            // 5: data property, empty
            else if ($(this).hasClass("dataItem") == true && $(this).find("div.datatypeProperties").length < 1) {
                // setupHandlers(this,"5");
			}
        });
    }

	function setupHandlers(property,type) {
		if (type == 1) { // object populated
			$(property).children("a.toggler").text("edit").attr("title","edit this item").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
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
		if (type == 2) { // object empty
			$(property).children("a.toggler").unbind().bind("click", function(){
				var propID = "#" + $(property).attr("id");
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
                var formLink = $(this).attr("href")+" .editForm";
                $(this).blur();
				$(editbox).toggleClass("editMode");
				if ($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
                    $(ajaxbox).append(loadingImg);
                    $(ajaxbox).load(formLink,"",function(){
                        $(editbox).find(".editForm").bind("submit", function(){ 
                            $(this).ajaxSubmit({success:function(){
                                loadNewContent(propID);
                                }                                
                            });
                            return false;
                        });
                    });
				} else {
					$(this).text("add").attr("title","add relationship").css("font-weight","normal");
				}
				return false;
			})
		}
		
		if (type == 3) { // multi data
			$(property).children("a.toggler").text("edit").attr("title","edit these items").unbind().bind("click", function(){
				$(this).blur();
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
				$(editbox).toggleClass("editMode");
				if($(editbox).hasClass("editMode")) { 
					$(this).text("close").css("font-weight","bold");
				} else {
					$(this).text("edit").css("font-weight","normal");
				}
			    if($(property).find("div.button").length < 1 && $(property).children("a.add").length > 0 ) {
					var link = $(property).children("a.toggler").attr("href");
		            $(editbox).append('<div class="button"><a class="addNewButton" href="' + link + '"><button>add new</button></a></div>');
		        }
				return false;
			})
		}
		
		if (type == 4) { // single data populated
			$(property).children("a.toggler").unbind().bind("click", function(){
				$(this).blur();
				var propID = "#" + $(property).attr("id");
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
                var formLink = $(this).attr("href")+" .editForm";
				$(editbox).toggleClass("editMode");
				if ($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
                    $(ajaxbox).load(formLink,"",function(){
                        $(this).parent("div.editBox").addClass("editing");
                        var textArea = $(ajaxbox).find("textarea").attr("id");
                        tinyMCE.execCommand("mceAddControl", true, textArea); 
                        $(editbox).find(".editForm").unbind().bind("submit", function(){ 
							tinyMCE.triggerSave(true,true);
							// need to catch empty values
                            $(this).ajaxSubmit({success:function(newcontent){
								tinyMCE.execCommand('mceRemoveControl', false, textArea); 
                                    // $(ajaxbox).empty().append(loadingImg);
                                    loadNewContent(newcontent,propID);
                                }                                
                            });
                            return false;
                        });
                    });
				} else {
					$(this).text("edit").attr("title","edit this text").css("font-weight","normal");
					$(propID).find("div.editBox").removeClass("editing");
                    var textArea = $(ajaxbox).find("textarea").attr("id");
                    tinyMCE.execCommand('mceRemoveControl', false, textArea); 
				}
				return false;
			})
		}
		
		if (type == 5) { // data empty
			$(property).children("a.toggler").unbind().bind("click", function(){
				$(this).blur();
				var propID = "#" + $(property).attr("id");
				var editbox = $(this).parent("div.propsItem").children("div.editBox");
				var ajaxbox = $(property).find("div.ajaxBox");
                var formLink = $(this).attr("href")+" .editForm";
				$(editbox).toggleClass("editMode");
				if ($(editbox).hasClass("editMode")) { 
					$(this).text("close").attr("title","close without saving").css("font-weight","bold");
                    $(ajaxbox).load(formLink,"",function(){
                        $(this).parent("div.editBox").addClass("editing");
                        var textArea = $(ajaxbox).find("textarea").attr("id");
                        tinyMCE.execCommand("mceAddControl", true, textArea); 
                        $(editbox).find(".editForm").unbind().bind("submit", function(){ 
							tinyMCE.triggerSave(true,true);
                            // tinyMCE.execCommand('mceRemoveControl', false, textArea); 
                            $(this).ajaxSubmit({dataType: 'xml', success:function(newcontent){
								var updateDiv = $(newcontent).find(propID);
                                // $(propID).replaceWith(updateDiv).removeClass("editing");
								tinyMCE.execCommand('mceRemoveControl', false, textArea); 
                                makeEditBoxes(propID);
                                makeTogglers(propID);
                                checkPropType(propID);
                                return false;
                                }                                
                            });
                            return false;
                        });
                    });
				} else {
					$(this).text("add").attr("title","add new entry").css("font-weight","normal");
					$(propID).find("div.editBox").removeClass("editing");
                    var textArea = $(ajaxbox).find("textarea").attr("id");
                    tinyMCE.execCommand('mceRemoveControl', false, textArea); 
				}
				return false;
			})
		}
	}
	
	function loadNewContent(propID,container) {
	    if (container != null) {container = container + " "} 
        else {container = "div.propsCategory "}
	    var url = thisPage + " " + propID;
		$("#swapBox").empty().load(url,'',function(){
    		$(container + propID).replaceWith($("#swapBox").children(propID));
            $("#swapBox").empty()
    	    makeEditBoxes(propID);
            makeTogglers(propID);
            checkPropType(propID);
            return false;
		});

	}

    //     tempID = "new_" + $("#swapBox").children().attr("id");  // some browsers are freaking out with more than one ID in the DOM
    //     $("#swapBox").children().attr("id",tempID);
    // $(propID).replaceWith($('#'+tempID));
    // $('#'+tempID).attr("id", tempID.substring(4));



	$("head").append('<style type="text/css"> \
						#contentwrap {background: #fff url(themes/vivo/site_icons/layout/bg_page_person.gif) no-repeat right top;} \
						.editBox a.edit, \
						    .editBox a.delete, \
						    #personWrap div.editBox a.delete {display:none} \
						.editBox.editMode a.edit, \
						    .editBox.editMode a.delete, \
						    #personWrap div.editBox.editMode a.delete {display:inline} \
						.editBox div.button {display:none} \
						.editBox.editMode div.button {display:block} \
						.editBox div.ajaxBox {display:none} \
						.editBox.editMode div.ajaxBox {display:block}\
						</style>');
						
    $("#content").prepend("<div id='swapBox' style='display:none'></div>");  // container for temporarily storing ajax content

    var MAX_DUMP_DEPTH = 10;
    var loadingImg = "<img style='border:0' class='img-center' src='themes/vivo/site_icons/loading.gif' alt=''/>";
    var thisPage = window.location.toString();
    
    makeTogglers();
    makeEditBoxes();
    checkPropType();
   
    function dumpObj(obj, name, indent, depth) {
           if (depth > MAX_DUMP_DEPTH) {
                  return indent + name + ": <Maximum Depth Reached>\n";
           }
           if (typeof obj == "object") {
                  var child = null;
                  var output = indent + name + "\n";
                  indent += "\t";
                  for (var item in obj)
                  {
                        try {
                               child = obj[item];
                        } catch (e) {
                               child = "<Unable to Evaluate>";
                        }
                        if (typeof child == "object") {
                               output += dumpObj(child, item, indent, depth + 1);
                        } else {
                               output += indent + item + ": " + child + "\n";
                        }
                  }
                  return output;
           } else {
                  return obj;
           }
    }
    

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
