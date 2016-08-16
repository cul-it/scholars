<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->


<footer role="contentinfo">
    <div class="row" style="background-color: #425675;margin:0;padding:16px 0 16px 30px">
		<div class="col-sm-6 col-md-6 col-lg-6">
			<nav role="navigation">
	            <ul class="footer-menu" role="list">
	                <li role="listitem"><a href="${urls.termsOfUse}" title="terms of use">Terms of Use</a></li>
					<li role="listitem">Powered by <a class="powered-by-vivo" href="http://vivoweb.org" target="_blank" title="powered by VIVO"><img src="${urls.base}/${themeDir}/images/vivo-badge.png" width="40" height="21" alt="VIVO Badge" /></a></li>
					<#if user.hasRevisionInfoAccess>
	                	<li role="listitem">Version: <a href="${version.moreInfoUrl}" title="version">${version.label}</a></li>
					</#if>
	            </ul>
	        </nav>
		</div>
		<div class="col-sm-6 col-md-6 col-lg-6">
    	<#if user.loggedIn>
			<nav role="navigation">
	            <ul id="footer-controls" class="footer-menu" role="list">
	                <li role="listitem"><a href="${urls.index}">Index</a></li>
					<#if user.hasSiteAdminAccess>
						<li role="listitem"><a href="${urls.siteAdmin}">Site Admin</a></li>
					</#if>
	                <li role="listitem"><a href="${urls.logout}">Logout</a></li>
	            </ul>
	        </nav>
		<#else>
        	<nav role="navigation">
	            <ul id="footer-controls" class="footer-menu" role="list">
	                <li role="listitem"><a href="${urls.about}" title="about">About</a></li>
	                <#if urls.contact??>
	                    <li role="listitem"><a href="${urls.contact}" title="contact us">Contact Us</a></li>
	                </#if> 
	                <li role="listitem"><a href="${urls.base}/authenticate?return=false" title="admin login">Administrators</a></li>
	            </ul>
	        </nav>
		</#if>
		</div>
    </div>
    <div class="wrapper cul-footer">

    <a href="https://www.library.cornell.edu/libraries">CORNELL UNIVERSITY LIBRARIES</a>
	<a class="btn-give" href="http://alumni.library.cornell.edu/content/give-library">GIVE TO THE LIBRARY</a>
    <nav>
        <p><strong>Library Resources:</strong></p>
        <ul>
            <li><a href="https://www.library.cornell.edu/">Library Website / </a></li>
            <li><a href="http://search.library.cornell.edu/">Search / </a></li>
            <li><a href="http://newcatalog.library.cornell.edu/">Catalog / </a></li>
            <li><a href="http://cornell.summon.serialssolutions.com/">Articles &amp; Full-Text / </a></li>
            <li><a href="http://newcatalog.library.cornell.edu/databases">Databases /</a></li>
            <li><a href="http://erms.library.cornell.edu/">E-journal Titles /</a></li>
            <li><a href="https://www.library.cornell.edu/visual-resources">Images</a></li>

        </ul>

    </nav>

    <p>©2016 Cornell University Library / <a href="tel:6072554144">(607) 255-4144 </a>  / <a href="https://www.library.cornell.edu/privacy">Privacy</a></p>

    

    </div>
</footer>

</footer><#include "scripts.ftl">
