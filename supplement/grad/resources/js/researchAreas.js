$(document).ready(function() {
    if ($("body").attr("id") == "researchareas") {
    
        clueTipSettings = {
           arrows: true, 
           dropShadow: true,
           positionBy: 'mouse',
           hoverIntent: false,
           mouseOutClose: true,
           waitImage: false,
           showTitle: false,
           width: 350,
           sticky: false,
           hoverIntent: {    
             sensitivity:  3,
             interval:     50,
             timeout:      0
           }
        };
        
        // text for status box
        var defaultStatusText = "Select research areas to see applicable Fields";
        var activeStatusText = "currently selected:";
        var inactiveStatusText = "";
        // dynamically inserted links
        var facultyHidden = "<a class='toggle showThem' href='#showfaculty'>Show faculty</a>";
        var facultyShown = "<a class='toggle hideThem' href='#hidefaculty'>Hide faculty</a>";
        var loadingBox = "<div class='loading'><img src='/resources/images/ajax-loader4.gif'/></div>";
        var deselectLink = "(<a href='#' class='toggle remove'>remove</a>)";
        // urls and params for ajax calls
        var allFieldURL = "/data/updateResearchAreas.jsp?showall=true";
        var baseURL = "/data/updateResearchAreas.jsp";
        var baseParamName = "?areas="
        var facultyParamName = "&showfaculty=";
        // global vars
        var lastSelected = "";
        var areaHash = "";
        var facultyHash = "";
        var showFaculty = false;
        var hash = document.location.hash;

        // DO THIS STUFF ON PAGE LOAD

            $("em.hide").show(); // text describing shift-click functions
    
            // Add these divs when the page loads
            $("#content").append("<div id='swapBox'></div>");
            $("#content").append("<div id='listBox'></div>");
            $("head").append("<style type='text/css'>em.hide{display:block}</style>");
        
            // This function gets run at the bottom
            function returnToState() {
                if (hash.length > 0) {
                    
                    amp = hash.indexOf("&");
                    
                    // Determine whether to make faculty lists shown or hidden
                    faculty = hash.substring(amp+1);
                    if(faculty=="showfaculty"){ 
                        showFaculty=true;
                        $("div.headingBox p").empty().html(facultyShown);
                        $("ul.facultyList").show();
                    }
                    if(faculty=="hidefaculty"){
                        showFaculty=false;
                        $("div.headingBox p").empty().html(facultyHidden);
                        $("ul.facultyList").hide();
                    }
                    
                    // Determine whether to change the selected areas
                    areas = hash.substring(1,amp).split(",");
                    if (areas.length >= 1) {
                        $("#scrollBox a.selected").removeClass("selected");
                        i=0;
                        while(i<areas.length) {
                            $("#scrollBox li#"+areas[i]+" a").addClass("selected");
                            i++; 
                        }
                        checkAreas();
                    }
                }
            }
    
        // CLICK HANDLERS
    
            // Capture clicks that select and deselect from the list of research areas
            $("#scrollBox ul a").click(function(e){
                var shiftPressed = e.shiftKey;
                var ctrlPressed = e.ctrlKey;
                lastSelected = $(this).parent().attr("id");
                loadBox();
                if ($(this).hasClass("selected")){
                    $(this).removeClass("selected");
                    $(this).blur();
                } else if (shiftPressed==true || ctrlPressed==true) {
                    $(this).addClass("selected");
                    $(this).blur();
                } else {
                    $("#scrollBox ul a.selected").removeClass("selected");
                    $(this).addClass("selected");
                    $(this).blur();
                } 
                checkAreas();
                return false;
            })
    
            // Capture clicks and control visiblity with the "Show faculty" and "Hide faculty" links
            function updateToggler() {
                $("div.headingBox a.showThem").unbind().click(function(){
                    $("div.headingBox p").empty().html(facultyShown);
                    $("ul.facultyList").show();
                    showFaculty = true;
                    facultyHash = "&showfaculty";
                    updateToggler();
                    return false;
                })
               $("div.headingBox a.hideThem").unbind().click(function(){
                    $("div.headingBox p").empty().html(facultyHidden);
                    $("ul.facultyList").hide();
                    showFaculty = false;
                    facultyHash = "&showfaculty";
                    updateToggler();
                    return false;
                })
            }
    
            // For the "remove" links for currently selected areas
            function updateRemoveLinks(){
                $("#statusBox a.remove").unbind().click(function(){
                    $(this).blur();
                    var areaID = $(this).parent("li").attr("class");
                    $("li#"+areaID+" a").removeClass("selected");
                    checkAreas();
                    return false;
                })
            }
    
            // When clicking "undo", remove the last area selected
            function undoLink(){
                $("div#fields a.undo").unbind().click(function(){
                    $("li#"+lastSelected+" a").removeClass("selected");
                    checkAreas();
                    return false;
                })
            }

            // Capture all clicks to Field and Faculty pages and update the hash for back-button functionality
            function bindExitLinks(){
                $("#fields ul.fieldList a").unbind().click(function(){ 
                    updateHash(); 
                });
                $("#fields ul.facultyList a").cluetip(clueTipSettings);
            }


        // FUNCTIONS

            // Check for selected areas
            function checkAreas(){
                var i = 0;
                var areaList = Array();
                $("#scrollBox ul a.selected").each(function(){
                    var thisArea = Array();
                    thisArea["id"] = $(this).parent().attr("id");
                    thisArea["label"] = $(this).text();
                    areaList[i] = thisArea;
                    i++; 
                })
                updateContent(areaList);
                updateStatus(areaList);
            }

            // Build a URL to grab new page content from the server
            function buildURL(areaList) {
                i=1;
                var areaParam = areaList[0]["id"];
                while (i < areaList.length) {
                    areaParam = areaParam + "," + areaList[i]["id"];
                    i++;
                }
                if (showFaculty==true) { 
                    url = baseURL+baseParamName+areaParam+facultyParamName+"yes";
                    areaHash = areaParam;
                    facultyHash = "&showfaculty";
                }
                if (showFaculty==false) {
                    url = baseURL+baseParamName+areaParam+facultyParamName+"no";
                    areaHash = areaParam;
                    facultyHash = "&hidefaculty";
                }
                return url;
            }

            // Go get that new content and load it in
            function updateContent(areaList) {
                if ( areaList.length > 0) {
                    var dataURL = buildURL(areaList);
                    $("#swapBox").empty().load(dataURL,function(){
                        var newContent = $("#swapBox").html();
                        $("div#fields").empty().append(newContent);
                        bindExitLinks();
                        undoLink();
                        updateToggler(); // the order these run seems to be important
                    });
                } 
                // load a full list of Fields into the listBox and keep it for reuse
                else if (areaList.length == 0) {
                    if ($("#listBox ul").length > 0) {
                        $("div#fields").empty().append($("#listBox").html());
                    } else {
                        $("#listBox").empty().load(allFieldURL,function(){
                            $("div#fields").empty().html($("#listBox").html());
                        });
                    }
                }
            }

            // Update the list of selected areas
            function updateStatus(areaList) {
                if (areaList.length == 0) {
                    $("#statusBox p").text(inactiveStatusText);
                    $("#statusBox").addClass("empty");
                    $("ul.selectedAreas").remove();
                    areaHash = null;
                }
        
                if (areaList.length > 0) {
                    $("#statusBox").removeClass("empty");
                    $("#statusBox p").text(activeStatusText);
                    if ($("ul.selectedAreas").length == 0) {
                        $("#statusBox").append("<ul></ul>");
                        $("#statusBox ul").addClass("selectedAreas");
                    }        
                    i = 0;
                    $("ul.selectedAreas").empty();
                    while (i < areaList.length) {
                        var areaLabel = areaList[i]["label"];
                        var areaID = areaList[i]["id"];
                        var listContents = "<li class='"+areaID+"'><strong>" + areaLabel + "</strong> " + deselectLink + "</li>";
                        $("ul.selectedAreas").append(listContents);
                        i++;
                    }
                updateRemoveLinks();
                }
            }
    
            // Just the little swirly loading image, gets wiped when content is finally loaded
            function loadBox(target) {
                $("div#fields ul").empty();
                $("div#fields").append(loadingBox);
            }

            // Updates the fragment identifier to allow for back-button functionality
            function updateHash() {
                if (showFaculty == true){
                    facultyHash = "&showfaculty";
                    document.location.hash = areaHash+facultyHash;
                }
                if (showFaculty == false){
                    facultyHash = "&hidefaculty";
                    document.location.hash = areaHash+facultyHash;
                }
            }
        
        // Run all these when the page is loaded
        returnToState();
        updateToggler();
        updateRemoveLinks();
        bindExitLinks();    
        $("#fields ul.facultyList a").cluetip(clueTipSettings);
    }
});
