/* $This file is distributed under the terms of the license in /doc/license.txt$ */

$(document).ready(function(){
        
    $.extend(this, individualLocalName);
        retrieveLocalStorage();
    // "more"/"less" HTML truncator for showing more or less content in data property core:overview
    $('.overview-value').truncate({max_length: 500});
    
    $.fn.exists = function () {
        return this.length !== 0;
    }
    
    $.fn.moreLess = function () {
        $(this).each
    }
    
    var togglePropDisplay = {
        showMore: function($toggleLink, $itemContainer) {
            $toggleLink.click(function() {
                $itemContainer.show();
                $(this).attr('href', '#show less content');
                $(this).text('less');
                togglePropDisplay.showLess($toggleLink, $itemContainer);
                return false;
            });
        },
        
        showLess: function($toggleLink, $itemContainer) {
            $toggleLink.click(function() {
                $itemContainer.hide();
                $(this).attr('href', '#show more content');
                $(this).text('more...');
                togglePropDisplay.showMore($toggleLink, $itemContainer);
                return false;
            });
        }
    };
    
    // var $propList = $('.property-list').not('>li>ul');
    var $propList = $('.property-list:not(:has(>li>ul))');
    $propList.each(function() {
        var $additionalItems = $(this).find('li:gt(4)');
        if ( $additionalItems.exists() ) {
            // create container for additional elements
            var $itemContainer = $('<div class="additionalItems" />').appendTo(this);
            
            // create toggle link
            var $toggleLink = $('<a class="more-less" href="#show more content">more...</a>').appendTo(this);
            
            $additionalItems.appendTo($itemContainer);
            
            $itemContainer.hide();
            
            togglePropDisplay.showMore($toggleLink, $itemContainer);
        }
    });
    
    var $subPropList = $('.subclass-property-list');
    $subPropList.each(function() {
        var $additionalItems = $(this).find('li:gt(4)');
        if ( $additionalItems.exists() ) {
            // create container for additional elements
            var $itemContainer = $('<div class="additionalItems" />').appendTo(this);
            
            // create toggle link
            var $toggleLink = $('<a class="more-less" href="#show more content">more...</a>').appendTo(this);
            
            $additionalItems.appendTo($itemContainer);
            
            $itemContainer.hide();
            
            togglePropDisplay.showMore($toggleLink, $itemContainer);
        }
    });
    
    var $subPropSibs = $subPropList.closest('li').last().nextAll();
    var $subPropParent = $subPropList.closest('li').last().parent();
    var $additionalItems = $subPropSibs.slice(3);
    if ( $additionalItems.length > 0 ) {
        // create container for additional elements
        var $itemContainer = $('<div class="additionalItems" />').appendTo($subPropParent);
        
        // create toggle link
        var $toggleLink = $('<a class="more-less" href="#show more content">more...</a>').appendTo($subPropParent);
        
        $additionalItems.appendTo($itemContainer);
        
        $itemContainer.hide();
        
        togglePropDisplay.showMore($toggleLink, $itemContainer);
    }
    
    // Change background color button when verbose mode is off
    $('a#verbosePropertySwitch:contains("Turn off")').addClass('verbose-off');
    
    // Reveal vCard QR code when QR icon is clicked
    $('#qrIcon, .qrCloseLink').click(function() {
        $('#qrCodeImage').toggleClass('hidden');
        return false;
    });

    // For pubs and grants on the foaf:person profile, and affiliated people
    // on the foaf:organization profile -- if a pub/grant/person has been hidden 
    // via the "manage" link, we need to ensure that the subclass heading gets removed
    // if there are no items to display for that subclass.
    $.each($('h3'), function() {
        if ( $(this).next().attr('class') == "subclass-property-list hideThis" ) {
            if ( $(this).next().children().length == 0 ) {       
                    $(this).closest('li').remove();
            }
        }
    });
        
    // if there are no selected pubs, hide the manage link; same for grants
    // and affiliated people on the org profile page
    if ( $('ul#authorInAuthorshipList').children('li').length < 1 && $('h3#authorInAuthorship').attr('class') != "hiddenPubs" ) {
        $('a#managePubLink').hide();
    }

    if ( $('ul#hasResearcherRoleList').children('li').length < 1 &&
            $('ul#hasPrincipalInvestigatorRoleList').children('li').length < 1 &&
            $('ul#hasCo-PrincipalInvestigatorRoleList').children('li').length < 1 &&
            $('ul#hasInvestigatorRoleList').children('li').length < 1 &&
            $('h3#hasResearcherRole').attr('class') != "hiddenGrants" ) {
                    $('a#manageGrantLink').hide();
    }

    if ( $('ul#organizationForPositionList').children('li').length < 1 && $('h3#organizationForPosition').attr('class') != "hiddenPeople" ) {
        $('a#managePeopleLink').hide();
    }
    // expands/collapses the div within each property group
    $.each($('section.property-group'), function() {
        var groupName = $(this).attr("id");
        $(this).children("nav").children("img").click(function() {
            if ( $("div[id='" + groupName + "Group']").is(":visible") ) {
                $("div[id='" + groupName + "Group']").slideUp(222);
                $(this).attr("src", $(this).attr("src").replace("collapse-prop-group","expand-prop-group"));
                $("section#" + groupName).children("h2").removeClass("expandedPropGroupH2");
            }
            else {
                $("div[id='" + groupName + "Group']").slideDown(222);
                $(this).attr("src", $(this).attr("src").replace("expand-prop-group","collapse-prop-group"));
                $("section#" + groupName).children("h2").addClass("expandedPropGroupH2");
            }
            manageLocalStorage();
        });
    });


    // expands/collapses all property groups together
    $.each($('a#propertyGroupsToggle'), function() {
        $('a#propertyGroupsToggle').click(function() {
            var anchorHtml = $(this).html();
            if ( anchorHtml.indexOf('expand') > -1 ) {
                $.each($('section.property-group'), function() {
                    $("div[id='" + $(this).attr("id") + "Group']").slideDown(222);
                    var innerSrc = $(this).children("nav").children("img").attr("src");
                    $(this).children("nav").children("img").attr("src",innerSrc.replace("expand-prop-group","collapse-prop-group"));
                    $(this).children("h2").addClass("expandedPropGroupH2");
                });
                $(this).html("collapse all");
            }
            else {
                $.each($('section.property-group'), function() {
                    $("div[id='" + $(this).attr("id") + "Group']").slideUp(222);
                    var innerSrc = $(this).children("nav").children("img").attr("src");
                    $(this).children("nav").children("img").attr("src",innerSrc.replace("collapse-prop-group","expand-prop-group"));
                    $(this).children("h2").removeClass("expandedPropGroupH2");
                });
                $(this).html("expand all");
            }
            manageLocalStorage();
        });
   }); 
   
    // if there are webpages but no contacts (email/phone), extend
    // the webpage border the full width
    if ( $('h2#contactHeading').length < 1 ) {
        $('div#webpagesContainer').css('width', '100%').css('clear','both');
    }

    //  Next two functions --  keep track of which property group tabs have been expanded,
    //  so if we return from a custom form or a related individual, even via the back button,
    //  the property groups will be expanded as before.
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
        var groups = [];
        $.each($('section.property-group').children("nav").children("img"), function() {
            if ( $(this).attr('src').indexOf('collapse-prop-group') > -1 ) {
                groups.push($(this).attr('groupName'));
            }
        });
        amplify.store(localName, groups);
        var checkLength = amplify.store(localName);
        if ( checkLength.length == 0 ) {
            amplify.store(localName, null);
        }
    }

    function retrieveLocalStorage() {
        var localName = this.individualLocalName;
        var groups = amplify.store(individualLocalName);
            if ( groups != undefined ) {
                for ( i = 0; i < groups.length; i++) {
                    var groupName = groups[i];
                    // unlikely, but it's possible a group that was previously opened and stored won't be displayed
                    // because the object properties would have been deleted. So ensure that the group in local
                    // storage has been rendered on the page. More likely, a user navigated from a quick view to a full
                    // profile, opened a group, then navigated back to the quick view where the group isn't rendered.
                    if ($("section#" + groupName).length ) {
                        $("div[id='" + groupName + "Group']").slideDown(1);
                        $("img[groupName='" + groupName + "']").attr("src", $("img[groupName='" + groupName + "']").attr("src").replace("expand-prop-group","collapse-prop-group"));
                        $("section#" + groupName).children("h2").addClass("expandedPropGroupH2");
                    }
                }
                if ( groups.length == $('section.property-group').length ) {
                    $('a#propertyGroupsToggle').html('collapse all');
                }
            }
        }
});
