<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->


<footer role="contentinfo">
    <div class="wrapper">
        <p class="copyright">
            <#if copyright??>
                <small>&copy;${copyright.year?c}
                <#if copyright.url??>
                    <a href="${copyright.url}" title="copyright">Cornell University Library</a>
                <#else>
                    Cornell University Library
                </#if>
                 | <a class="terms" href="${urls.termsOfUse}" title="terms of use">Terms of Use</a></small> | 
            </#if>
            Powered by <a class="powered-by-vivo" href="http://vivoweb.org" target="_blank" title="powered by VIVO"><img src="${urls.base}/${themeDir}/images/vivo-badge.png" width="40" height="21" alt="VIVO Badge" /></a>
            <#if user.hasRevisionInfoAccess>
                 | Version <a href="${version.moreInfoUrl}" title="version">${version.label}</a>
            </#if>
        </p>
    	<#if user.loggedIn>
			<nav role="navigation">
	            <ul id="footer-nav" role="list">
	                <li role="listitem"><a href="${urls.index}">Index</a></li>
					<#if user.hasSiteAdminAccess>
						<li role="listitem"><a href="${urls.siteAdmin}">Site Admin</a></li>
					</#if>
	                <li role="listitem"><a href="${urls.logout}">Logout</a></li>
	            </ul>
	        </nav>
		<#else>
        	<nav role="navigation">
	            <ul id="footer-nav" role="list">
	                <li role="listitem"><a href="${urls.about}" title="about">About</a></li>
	                <#if urls.contact??>
	                    <li role="listitem"><a href="${urls.contact}" title="contact us">Contact Us</a></li>
	                </#if> 
	                <li role="listitem"><a href="${urls.base}/authenticate?return=false" title="admin login">Administrators</a></li>
	            </ul>
	        </nav>
		</#if>
    </div>
</footer>
<#include "scripts.ftl">
