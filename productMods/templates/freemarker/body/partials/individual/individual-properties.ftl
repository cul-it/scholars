<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for property listing on individual profile page -->

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

<#list propertyGroups.all as group>
    <#assign groupName = group.getName(nameForOtherGroup)>
    <#assign groupNameHtmlId = p.createPropertyGroupHtmlId(groupName) >
    <#assign verbose = (verbosePropertySwitch.currentValue)!false>
<section id="${groupNameHtmlId}" class="property-group" role="region" style="<#if (sectionCount > 1) >display:none<#else>display:block</#if>">
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

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-property-groups.css" />')}
${headScripts.add('<script type="text/javascript" src="${urls.base}/js/amplify/amplify.store.min.js"></script>')}
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/propertyGroupControls.js?vers=1.5.1tabs"></script>')}

