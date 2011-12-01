<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for core:webpage 

    Note that this template is not used for webpage deletion, since deletion occurs from the
    Manage Webpages page, so it's okay to reference individual.
-->

<@showWebpage statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement 
-->
     
<#macro showWebpage statement>
    <#local linkText>
        <#if statement.anchor?has_content>${statement.anchor}<#t>
        <#elseif statement.url?has_content>${statement.url}<#t>
        </#if>    
    </#local>

    <#if statement.url?has_content>
       <#if individual?? && individual.organization>
            <a title="official page for ${statement.url}" href="${statement.url}"><img class="org-webThumbnail" src="http://mannlib.websnapr.com/?url=${statement.url}&size=m" alt="screenshot of webpage ${statement.url}"/></a>
            <a class="org-url" href="${statement.url}">${linkText}</a>      
        <#else>
            <a href="${statement.url}">${linkText}</a>
        </#if>
    <#else>
        <a href="${profileUrl(statement.uri("link"))}">${statement.linkName}</a> (no url provided for link)
    </#if>
</#macro>