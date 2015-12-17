<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "cu-identity.ftl">

<header id="branding" role="banner">
<h1 class="vivo-logo"><a title="Research and Scholarship across Cornell" href="${urls.home}"><span class="displace">${siteName}</span></a></h1>
    <#-- Since we are using a graphic text for the tagline, we won't render ${siteTagline}
    <#if siteTagline?has_content>
        <em>${siteTagline}</em>
    </#if>-->

    <nav role="navigation">
        <ul id="header-nav" role="list">
            <li role="listitem"><a href="${urls.index}" title="index">Index</a></li>
            <#if user.loggedIn>
                <#if user.hasSiteAdminAccess>
                    <li role="listitem"><a href="${urls.siteAdmin}" title="site admin">Site Admin</a></li>
                </#if>
                    <li>
                        <ul class="dropdown">
                            <li id="user-menu"><a href="#">${user.loginName}</a>
                                <ul class="sub_menu">
                                     <#if user.hasProfile>
                                         <li role="listitem"><a href="${user.profileUrl}" title="my VIVO page">My VIVO page</a></li>
                                     </#if>
                                     <#if urls.myAccount??>
                                         <li role="listitem"><a href="${urls.myAccount}" title="my account">My account</a></li>
                                     </#if>
                                     <li role="listitem"><a href="${urls.logout}" title="log out">Log out</a></li>
                                </ul>
                            </li>
                         </ul>
                     </li>
                
                ${scripts.add('<script type="text/javascript" src="${urls.base}/js/userMenu/userMenuUtils.js"></script>')}
                
            <#else>
                <li role="listitem"><a class="log-out" title="log in to manage this site" href="${urls.login}">Log in</a></li>
            </#if>
        </ul>
    </nav>
