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
       <#if individual?? && individual.organization()>
            <a title="Click to view the ${linkText} offical web page" href="${statement.url}"><img class="org-webThumbnail" src="http://vivo.cornell.edu/webImageCapture?url=${statement.url}" alt="screenshot of webpage ${statement.url}" style="float:left;margin-bottom:15px"/></a>
            <a title="Click to view the ${linkText} offical web page" href="${statement.url}" style="float:left;margin-left:-232px;margin-top:119px">
                <img src="${urls.images}/individual/weblinkIconLarge.png"  alt="click webpage icon"/>  
            </a>  
        <#else>
            <a href="${statement.url}">${linkText}</a>
        </#if>
    <#else>
        <a href="${profileUrl(statement.uri("link"))}">${statement.linkName}</a> (no url provided for link)
    </#if>
</#macro>

