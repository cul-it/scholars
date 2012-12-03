<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for core:webpage 

    Note that this template is not used for webpage deletion, since deletion occurs from the
    Manage Webpages page, so it's okay to reference individual.
-->
<#assign count = property.statements?size!> 

<#assign identifier>
    <#if statement.url?has_content>${statement.url?replace(":","")?replace("/","")?replace(".","-")}<#t>
    <#else>"noUrl"<#t>
    </#if>    
</#assign>

<@showWebpage statement count identifier />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement 
-->
     
<#macro showWebpage statement count identifier>

    <#local linkText>
        <#if statement.anchor?has_content>${statement.anchor}<#t>
        <#elseif statement.url?has_content>${statement.url}<#t>
        </#if>    
    </#local>
    
    <#local imgSize = "&thumbnail=true" >

    <#if (statement.rank?? && statement.rank == "1") || ( count == 1 ) >
         <#local imgSize = "" >
    </#if>

    <#if statement.url?has_content>
        <#if individual?? && individual.organization()>
            <span class="webpage-indicator" id="span-${identifier}" >Loading website image. . .&nbsp;&nbsp;&nbsp;<img  src="${urls.images}/indicatorWhite.gif"></span>
            <div id="${identifier}" style="display:none;">
            <a title="Click to view the ${linkText} offical web page" href="${statement.url}">
                <img id="img-${identifier}" class="org-webThumbnail" src="http://vivo.cornell.edu/webImageCapture?url=${statement.url}${imgSize}" alt="screenshot of webpage ${statement.url}" /></a>
            <#if imgSize == "" >
                <a class="weblink-icon" title="Click to view the ${linkText} web page" href="${statement.url}" >
                    <img src="${urls.images}/individual/weblinkIconLarge.png"  alt="click webpage icon"/>  
                </a>
            <#else>
                <a class="weblink-icon" title="Click to view the ${linkText} web page" href="${statement.url}">
                    <img src="${urls.images}/individual/weblinkIconSmall.png"  alt="click webpage icon"/>  
                </a>
            </#if>
            </div>
        <#else>
            <a href="${statement.url}">${linkText}</a>
        </#if>
    <#else>
        <a href="${profileUrl(statement.uri("link"))}">${statement.linkName}</a> (no url provided for link)
    </#if>
</#macro>
<#if individual?? && individual.organization()>
<script>
$('img#img-${identifier}').load(function(){
    $('span#span-${identifier}').hide();
    $('div#${identifier}').fadeIn();
});
</script>
</#if>