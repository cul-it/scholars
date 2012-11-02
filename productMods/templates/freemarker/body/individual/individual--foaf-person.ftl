<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "individual-setup.ftl">

<#-- 
     Which view does the individual want people to see, the standard view or the webpage view?
-->
<#assign selectedTemplate = "individual--foaf-person-standard.ftl" >
<#assign profilePageType = profileType >

<#-- targetedView takes precedence over the profilePageType. -->
<#if targetedView?has_content>
    <#if targetedView != "standardView">
        <#assign selectedTemplate = "individual--foaf-person-quickview.ftl" >
    </#if>
<#elseif profilePageType == "quickView" >
        <#assign selectedTemplate = "individual--foaf-person-quickview.ftl" >
</#if>

<#include selectedTemplate >


