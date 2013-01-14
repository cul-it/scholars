/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){
        
    $.extend(this, individualLocalName);
    
    retrieveLocalStorage();

    // controls the property group tabs
    $.each($('li.clickable'), function() {
        var groupName = $(this).attr("groupName");
        var $propertyGroupLi = $(this);
        
        $(this).click(function() {
            if ( $propertyGroupLi.attr("class") == "nonSelectedGroupTab clickable" ) {
                $.each($('li.selectedGroupTab'), function() {
                    $(this).removeClass("selectedGroupTab clickable");
                    $(this).addClass("nonSelectedGroupTab clickable");
                });
                $propertyGroupLi.removeClass("nonSelectedGroupTab clickable");
                $propertyGroupLi.addClass("selectedGroupTab clickable");
            }
            var $visibleSection = $('section.property-group:visible');
            $visibleSection.hide();
            $('section#' + groupName).show();
            manageLocalStorage();
            return false;
        });
    });
   
    //  Next two functions --  keep track of which property group tab was selected,
    //  so if we return from a custom form or a related individual, even via the back button,
    //  the same property group will be selected as before.
    function manageLocalStorage() {
        var localName = this.individualLocalName;
        // is this individual already stored? If not, how many have been stored?
        // If the answer is 3, remove the first one in before adding the new one
        var current = amplify.store(localName);
        var profiles = amplify.store("profiles");
        if ( current == undefined ) {
            if ( profiles == undefined ) {
                var lnArray = [];
                lnArray.push(localName);
                amplify.store("profiles", lnArray);
            }
            else if ( profiles != undefined && profiles.length >= 3 ) {
                firstItem = profiles[0];
                amplify.store(firstItem, null);
                profiles.splice(0,1);
                profiles.push(localName);
                amplify.store("profiles", profiles)
            }
            else if ( profiles != undefined && profiles.length < 3 ) {
                profiles.push(localName);
                amplify.store("profiles", profiles)
            }
        }
        var selectedTab = [];
        selectedTab.push($('li.selectedGroupTab').attr('groupName'));

        amplify.store(localName, selectedTab);
        var checkLength = amplify.store(localName);
        if ( checkLength.length == 0 ) {
            amplify.store(localName, null);
        }
    }

    function retrieveLocalStorage() {
        var localName = this.individualLocalName;
        var selectedTab = amplify.store(individualLocalName);
        
        if ( selectedTab != undefined ) {
            var groupName = selectedTab[0];
            
            // unlikely, but it's possible a tab that was previously selected and stored won't be displayed
            // because the object properties would have been deleted (in non-edit mode). So ensure that the tab in local
            // storage has been rendered on the page.     
            if ( $("ul.propertyTabsList li[groupName='" + groupName + "']").length ) {        
                // if the selected tab is the default first one, don't do anything
                if ( $('li.clickable').first().attr("groupName") != groupName ) {   
                    // deselect the default first tab
                    var $firstTab = $('li.clickable').first();
                    $firstTab.removeClass("selectedGroupTab clickable");
                    $firstTab.addClass("nonSelectedGroupTab clickable");
                    // select the stored tab
                    $("li[groupName='" + groupName + "']").removeClass("nonSelectedGroupTab clickable");
                    $("li[groupName='" + groupName + "']").addClass("selectedGroupTab clickable");
                    // hide the first tab section
                    $('section.property-group:visible').hide();
                    // show the selected tab section
                    $('section#' + groupName).show();
                }
            }
        }
    }
});
