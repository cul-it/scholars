<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for core:webpage.
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
     http://mannlib.websnapr.com/?url=${statement.url}&size=${imgSize}
 -->
<@showWebpage statement />

<#macro showWebpage statement>
<#local linkText>
    <#if statement.anchor?has_content>${statement.anchor}<#t>
    <#elseif statement.url?has_content>${statement.url}<#t>
    </#if>    
</#local>
<#local imgSize = "&thumbnail=true" >

<#if (statement.rank?? && statement.rank == "1") >
     <#local imgSize = "" >
</#if>
<#if statement.url?has_content>
        <a title="Click to view the ${linkText} web page" href="${statement.url}">
            <img class="org-webThumbnail" src="http://vivo.cornell.edu/webImageCapture?url=${statement.url}${imgSize}" alt="screenshot of webpage ${statement.url}" />

        </a>
        <#if imgSize == "" >
            </li>
            <li class="weblinkLarge">  
            <a title="Click to view the ${linkText} web page" href="${statement.url}">
                <img src="${urls.images}/individual/weblinkIconLarge.png"  alt="click webpage icon"/>  
            </a>
        <#else>
            </li>
            <li class="weblinkSmall">  
            <a title="Click to view the ${linkText} web page" href="${statement.url}">
                <img src="${urls.images}/individual/weblinkIconSmall.png"  alt="click webpage icon"/>  
            </a>
        </#if>
<#else>
    <a href="${profileUrl(statement.uri("link"))}" title="link name">${statement.linkName}</a> (no url provided for link)
</#if>
</#macro>