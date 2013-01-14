<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for property listing on individual profile page -->
<style>
ul.propertyTabsList  {
    margin-left: 4px;
    margin-top: 24px
}
ul.propertyTabsList li {
    font-size: 1.0em;
}
ul.propertyTabsList li:first-child {
    width: 7px;
}
li.nonSelectedGroupTab {
    float:left;
    border: 1px solid #DFE6E5;
    background-color:#E4ECF3;
    padding: 6px 8px 6px 8px;
    cursor:pointer;
    border-top-right-radius: 4px;
    -moz-border-radius-topright: 4px;
    -webkit-border-top-right-radius: 4px;
    border-top-left-radius: 4px;
    -moz-border-radius-topleft: 4px;
    -webkit-border-top-left-radius: 4px;
}
li.selectedGroupTab {
    float:left;
    border: 1px solid #DFE6E5;
    border-bottom-color:#fff;
    background-color:#FFF;
    padding: 6px 8px 6px 8px;
    border-top-right-radius: 4px;
    -moz-border-radius-topright: 4px;
    -webkit-border-top-right-radius: 4px;
    border-top-left-radius: 4px;
    -moz-border-radius-topleft: 4px;
    -webkit-border-top-left-radius: 4px;
}
li.groupTabSpacer {
    float:left;border-bottom: 1px solid #DFE6E5;background-color:#fff;width:3px;height:37px
}

</style>

<#import "lib-properties.ftl" as p>
<#assign subjectUri = individual.controlPanelUrl()?split("=") >
<#assign tabCount = 1 >
<#assign sectionCount = 1 >
<ul class="propertyTabsList">
    <li  class="groupTabSpacer">&nbsp;</li>
<#list propertyGroups.all as groupTabs>
    <#assign groupName = groupTabs.getName(nameForOtherGroup)>
    <#if groupName?has_content>
		<#--the function replaces spaces in the name with underscores, also called for the property group menu-->
    	<#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
    <#else>
        <#assign groupName = "Properties">
    	<#assign groupNameHtmlId = "properties" >
    </#if>
        <#if tabCount = 1 >
            <li class="selectedGroupTab clickable" groupName="${groupNameHtmlId}">${groupName?capitalize}</li>
            <li class="groupTabSpacer">&nbsp;</li>
            <#assign tabCount = 2>
        <#else>
            <li class="nonSelectedGroupTab clickable" groupName="${groupNameHtmlId}">${groupName?capitalize}</li>
            <li class="groupTabSpacer">&nbsp;</li>
        </#if>
</#list>
    <li  class="groupTabSpacer">&nbsp;</li>
</ul>
<script>
    var width = 0;
    $('ul.propertyTabsList li').each(function() {
        width += $(this).outerWidth();
    });

    if ( width < 922 ) {
        var diff = 926-width;
        $('ul.propertyTabsList li:last-child').css('width', diff + 'px');
    }
    else {
        var diff = width-926;
        if ( diff < 26 ) {
            $('ul.propertyTabsList li').css('font-size', "0.96em");
        }
        else if ( diff > 26 && diff < 50 ) {
            $('ul.propertyTabsList li').css('font-size', "0.92em");
        }
        else if ( diff > 50 && diff < 80 ) {
            $('ul.propertyTabsList li').css('font-size', "0.9em");
        }
        else if ( diff > 80 && diff < 130 ) {
            $('ul.propertyTabsList li').css('font-size', "0.84em");
        }
        else if ( diff > 130 && diff < 175 ) {
            $('ul.propertyTabsList li').css('font-size', "0.8em");
        }
        else if ( diff > 175 && diff < 260 ) {
            $('ul.propertyTabsList li').css('font-size', "0.73em");
        }
        else {
            $('ul.propertyTabsList li').css('font-size', "0.7em");
        }

        // get the new width
        var newWidth = 0
        $('ul.propertyTabsList li').each(function() {
            newWidth += $(this).outerWidth();
        });
        var newDiff = 926-newWidth;
        $('ul.propertyTabsList li:last-child').css('width', newDiff + 'px');

    }

</script>

<#list propertyGroups.all as group>
    <#assign groupName = group.getName(nameForOtherGroup)>
    <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
    <#assign verbose = (verbosePropertySwitch.currentValue)!false>
<section id="${groupNameHtmlId}" class="property-group" role="region" style="border-top:none;<#if (sectionCount > 1) >display:none<#else>display:block</#if>">
    <#-- List the properties in the group   -->
        <div id="${groupNameHtmlId}Group" >
        <#list group.properties as property>
            <article class="property" role="article">
                <#-- Property display name -->
                <#if property.localName == "authorInAuthorship" && editable  >
                    <h3 id="${property.localName}">${property.name} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="managePubLink" class="manageLinks" href="${urls.base}/managePublications?subjectUri=${subjectUri[1]!}" title="manage publications" <#if verbose>style="padding-top:10px"</#if> >
                            manage publications
                        </a>
                    </h3>
                <#elseif property.localName == "hasResearcherRole" && editable  >
                    <h3 id="${property.localName}">${property.name} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="manageGrantLink" class="manageLinks" href="${urls.base}/manageGrants?subjectUri=${subjectUri[1]!}" title="manage grants & projects" <#if verbose>style="padding-top:10px"</#if> >
                            manage grants & projects
                        </a>
                    </h3>
                <#elseif property.localName == "organizationForPosition" && editable  >
                    <h3 id="${property.localName}">${property.name} <@p.addLink property editable /> <@p.verboseDisplay property /> 
                        <a id="managePeopleLink" class="manageLinks" href="${urls.base}/managePeople?subjectUri=${subjectUri[1]!}" title="manage people" <#if verbose>style="padding-top:10px"</#if> >
                            manage affiliated people
                        </a>
                    </h3>
                <#else>
                    <h3 id="${property.localName}">${property.name} <@p.addLink property editable /> <@p.verboseDisplay property /> </h3>
                </#if>
                <#-- List the statements for each property -->
                <ul class="property-list" role="list" id="${property.localName}List">
                    <#-- data property -->
                    <#if property.type == "data">
                        <@p.dataPropertyList property editable />
                    <#-- object property -->
                    <#else>
                        <@p.objectProperty property editable />
                    </#if>
                </ul>
            </article> <!-- end property -->
        </#list>
    </div>
</section> <!-- end property-group -->
<#assign sectionCount = 2 >
</#list>
<script>
    $.each($('section.property-group'), function() {
        var sectionHeight = $(this).height();
        if ( sectionHeight < 1000 ) {
            $(this).css('margin-bottom', 1000-sectionHeight + "px");
        }
    });
</script>
