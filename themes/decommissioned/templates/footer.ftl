<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

</div> <!-- #wrapper-content -->

<footer role="contentinfo">
    <div class="wrapper">
        <p class="copyright" style="float:left">
            <#if copyright??>
                <small>&copy;${copyright.year?c}
                <#if copyright.url??>
                    <a href="${copyright.url}" title="copyright">${copyright.text}</a>
                <#else>
                    ${copyright.text}
                </#if>
                 | <a class="terms" href="${urls.termsOfUse}" title="terms of use">Terms of Use</a></small> | 
            </#if>
            Powered by <a class="powered-by-vivo" href="http://vivoweb.org" target="_blank" title="powered by VIVO"><img src="${urls.base}/${themeDir}/images/vivo-badge.png" width="40" height="21" alt="VIVO Badge" /></a>
            <#if user.hasRevisionInfoAccess>
                 | Version <a href="${version.moreInfoUrl}" title="version">${version.label}</a>
            </#if>
        </p>
		<p style="float:right;margin-right:12px"><a href="${urls.contact}" title="contact us">Questions?</a></p>
    
    </div>
</footer>

<#include "scripts.ftl">