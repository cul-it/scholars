<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Macros used to build the statistical information on the home page -->

<#-- Renders the html for the research facilities section on the home page. -->
<#-- Works in conjunction with the vivocornellHomePageUtils.js file -->
<#macro researchFacsHtml>
    <section id="home-research-facs" class="home-sections">
        <h4>Research Facilities</h4>
        <div id="research-facs">
        </div>
    </section>
</#macro>

<#-- builds the "research facilities" box on the home page -->
<#macro listResearchFacilities>
<script>
var researchFacilities = [
<#if researchFacsDG?has_content>
    <#list researchFacsDG as resultRow>
        <#assign uri = resultRow["facURI"] />
        <#assign label = resultRow["name"] />
        <#assign localName = uri?substring(uri?last_index_of("/")) />
            {"uri": "${localName}", "name": "${label}"}<#if (resultRow_has_next)>,</#if>
    </#list>        
</#if>
];
var urlsBase = "${urls.base}";
</script>
</#macro>

<#-- renders the "geographic focus" section on the home page. works in      -->
<#-- conjunction with the homePageMaps.js and latLongJson.js files, as well -->
<#-- as the leaflet javascript library.                                     -->
<#macro geographicFocusHtml>
    <section id="home-geo-focus" class="home-sections">
        <h4>Geographic Focus</h4>
            <div id="mapControls">
                <a id="globalLink" class="selected" href="javascript:">Global Research</a>&nbsp;|&nbsp;
                <a id="usLink" href="javascript:">U.S. Research</a>&nbsp;|&nbsp;
                <a id="nyLink" href="javascript:">New York Research</a>  
            </div>  
        <div id="researcherTotal"></div>
        <div id="timeIndicatorGeo">
            <span>Loading map information . . .&nbsp;&nbsp;&nbsp;
                <img  src="${urls.images}/indicatorWhite.gif">
            </span>
        </div>
        <div id="mapGlobal" class="mapArea"></div>
        <div id="mapUS" class="mapArea"></div>
        <div id="mapNY" class="mapArea"></div>
    </section>
</#macro>

<#-- WILL NEED TO ACTIVATE THIS SECTION WHEN WE GO TO RELEASE 1.6
<#macro researchClasses classGroups=vClassGroups>
    <#assign foundClassGroup = false />
    <section id="home-research" class="home-sections">
        <h4>${i18n().research_capitalized}</h4>
        <ul>
            <#list classGroups as group>
                <#if (group.individualCount > 0) && group.displayName == "research" >
                    <#assign foundClassGroup = true />
                    <#list group.classes as class>
                        <#if (class.name == "Academic Article" || class.name == "Book" || class.name == "Conference Paper" ||class.name == "Media Contribution" || class.name == "Report" || class.name == "Library Collection") && (class.individualCount > 0)>
                            <li role="listitem"><span>${class.individualCount!}</span>&nbsp;<a href='${urls.base}/individuallist?vclassId=${class.uri?replace("#","%23")!}'>${class.name}s</a></li>
                        </#if>
                    </#list>
                    <li><a href="${urls.base}/research" alt="${i18n().view_all_research}">${i18n().view_all}</a></li>
                </#if>
            </#list>
            <#if !foundClassGroup>
                <p><li>${i18n().no_research_content_found}</li></p> 
            </#if>
        </ul>
    </section>
</#macro>
-->