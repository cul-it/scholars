<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for sparkline visualization on individual profile page -->

<#-- Determine whether this person is an author -->
<#assign isAuthor = p.hasStatements(propertyGroups, "${core}authorInAuthorship") />

<#-- Determine whether this person is involved in any grants -->
<#assign isInvestigator = ( p.hasStatements(propertyGroups, "${core}hasInvestigatorRole") ||
                            p.hasStatements(propertyGroups, "${core}hasPrincipalInvestigatorRole") || 
                            p.hasStatements(propertyGroups, "${core}hasCo-PrincipalInvestigatorRole") ) >

<#if (isAuthor || isInvestigator)>
 
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/visualization/visualization.css" />')}
    <#assign standardVisualizationURLRoot ="/visualization">
    
    <section id="visualization" role="region">
        <#if isAuthor>
            <#assign coAuthorIcon = "${urls.images}/visualization/coauthorship/co_author_icon.png">
            <#assign mapOfScienceIcon = "${urls.images}/visualization/mapofscience/scimap_icon.png">
            <#assign coAuthorVisUrl = individual.coAuthorVisUrl()>
            <#assign mapOfScienceVisUrl = individual.mapOfScienceUrl()>
            
            <#assign googleJSAPI = "https://www.google.com/jsapi?autoload=%7B%22modules%22%3A%5B%7B%22name%22%3A%22visualization%22%2C%22version%22%3A%221%22%2C%22packages%22%3A%5B%22imagesparkline%22%5D%7D%5D%7D"> 
            <div class="collaboratorship-link-separator-solid"></div>
            <span id="sparklineHeading">Publications in VIVO</span>   
            <div id="vis_container_coauthor">&nbsp;</div>
            
            <div class="collaboratorship-link-separator-solid"></div>
            <p id="networks">Networks</p>
                    <span id="coauthor-link" class="collaboratorship-link"><a href="${coAuthorVisUrl}" title="co-author"><img src="${coAuthorIcon}" alt="Co-author network icon" width="20px" height="20px" /></a>
                <a href="${coAuthorVisUrl}" title="co-author network">Co-Authors</a></span><p style="margin-top:-10px"></p>
         </#if>   
            <#if isInvestigator>
                <#if !isAuthor >
                    <div class="collaboratorship-link-separator-solid"></div>
                    <p id="networks">Networks</p>
                </#if>
                <#assign coInvestigatorVisUrl = individual.coInvestigatorVisUrl()>
                <#assign coInvestigatorIcon = "${urls.images}/visualization/coauthorship/co_investigator_icon.png">

                        <span class="collaboratorship-link"><a href="${coInvestigatorVisUrl}" title="co-investigator network"><img src="${coInvestigatorIcon}" alt="Co-investigator network icon" width="20px" height="20px" /></a>
                    <a href="${coInvestigatorVisUrl}" title="co-investigator network">Co-Investigators</a></span>
            </#if>
            <#if isAuthor>
            <div class="collaboratorship-link-separator-solid"></div>
            
                    <span class="collaboratorship-link"><a href="${mapOfScienceVisUrl}" title="map of science"><img src="${mapOfScienceIcon}" alt="Map Of Science icon" width="20px" height="20px" /></a>
                <a href="${mapOfScienceVisUrl}" title="map of science">Map Of Science</a></span>
            
            ${scripts.add('<script type="text/javascript" src="${googleJSAPI}"></script>',
                          '<script type="text/javascript" src="${urls.base}/js/visualization/visualization-helper-functions.js"></script>',
                          '<script type="text/javascript" src="${urls.base}/js/visualization/sparkline.js"></script>')}           
            </#if>
            
            <script type="text/javascript">
                var visualizationUrl = '${urls.base}/visualizationAjax?uri=${individual.uri?url}';
                var infoIconSrc = '${urls.images}/iconInfo.png';
            </script>
            
    </section> <!-- end visualization -->
</#if>