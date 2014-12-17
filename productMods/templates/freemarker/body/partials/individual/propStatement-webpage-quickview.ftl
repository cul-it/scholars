<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for core:webpage.
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
     http://mannlib.websnapr.com/?url=${statement.url}&size=${imgSize}
 -->
 
<#assign count = property.statements?size!> 

<#assign identifier>
    <#if statement.url?has_content>
        ${statement.url?replace("[^\\p{L}\\p{N}]","","r")}<#t>
    <#else>
        "noUrl"<#t>
    </#if>    
</#assign>


<@showWebpage statement count identifier/>

<#macro showWebpage statement count identifier>
<#local linkText>
    <#if statement.label?has_content>${statement.label}<#t>
    <#elseif statement.url?has_content>${statement.url}<#t>
    </#if>    
</#local>
<#local imgSize = "&thumbnail=true" >

<#if (statement.rank?? && statement.rank == "1") || ( count == 1 ) >
     <#local imgSize = "" >
</#if>
<#if statement.url?has_content>
<span id="span-${identifier}" class="webpage-indicator-qv">Loading website image. . .&nbsp;&nbsp;&nbsp;<img  src="${urls.images}/indicatorWhite.gif"></span>
        <a title="Click to view the ${linkText} web page" href="${statement.url?url}">
            <img id="img-${identifier}" class="org-webThumbnail" src="http://vivo.cornell.edu/webImageCapture?url=${statement.url?url}${imgSize}" alt="screenshot of webpage ${statement.url}" style="display:none"/>

        </a>
        <#if imgSize == "" >
            </li>
            <li class="weblinkLarge">  
            <a title="Click to view the ${linkText} web page" href="${statement.url?url}">
                <img id="icon-${identifier}" src="${urls.images}/individual/weblinkIconLarge.png"  alt="click webpage icon" style="display:none"/>  
            </a>
        <#else>
            </li>
            <li class="weblinkSmall">  
            <a title="Click to view the ${linkText} web page" href="${statement.url?url}">
                <img id="icon-${identifier}" src="${urls.images}/individual/weblinkIconSmall.png"  alt="click webpage icon" style="display:none"/>  
            </a>
        </#if>
<#else>
    <a href="${profileUrl(statement.uri("link"))}" title="link name">${statement.linkName}</a> (no url provided for link)
</#if>

</#macro>

<script>

$('img#img-${identifier}').load(function(){
    $('span#span-${identifier}').hide();
    $('img#img-${identifier}').fadeIn();
    $('img#icon-${identifier}').fadeIn();
});
</script>