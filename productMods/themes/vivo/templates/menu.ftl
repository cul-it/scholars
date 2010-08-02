<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#import "listMacros.ftl" as l>

<div id="header">
  
  <a class="image vivoLogo" href="${urls.home}" title="Home"><img src="${siteIconPath}/vivo_logo.gif" alt="VIVO" /></a>
  
  <div id="menu">
    <ul id="primary">
        <#list tabMenu.items as item>
            <li>
                <a href="${item.url}" <#if item.active> class="activeTab" </#if>>
                    ${item.linkText}
                </a>
            </li>
        </#list>
    </ul>
    <ul id="secondary">
        <@l.firstLastList>
            <#if loginName??>
                <li>Logged in as <strong>${loginName}</strong> (<a class="logoutMenu" href="${urls.logout}">Log out</a>)</li>
                <li><a href="${urls.siteAdmin}">Site Admin</a></li>
            <#else>
                <li><a title="log in to manage this site" href="${urls.login}">Log in</a></li>
            </#if> 
            
                <li><a href="browse">Index</a></li>
            
                <li><a href="${urls.about}">About</a></li>
            <#if urls.contact??>
                <li><a href="${urls.contact}">Contact Us</a></li>
            </#if>
        </@l.firstLastList>       
    </ul>
  </div><!-- menu -->
</div><!-- header -->