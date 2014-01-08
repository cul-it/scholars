<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Icon controls displayed in upper-right corner -->
<#-- CU directory link -->
<#assign netid = individual.selfEditingId()!>
<img id="uriIcon" title="${individual.uri}" src="${urls.images}/individual/share-uri-icon.png" alt="share the uri" />
<@qr.renderCode "qr-code-icon.png"/>
<#if netid?has_content>
    <a href="http://www.cornell.edu/search/?tab=people&netid=${netid}" title="Cornell University directory entry for ${netid}" target="_blank">
        <img src="${urls.images}/individual/contact-info-icon.png"  title="view additional contact information" alt="contact info" />
    </a>
</#if>