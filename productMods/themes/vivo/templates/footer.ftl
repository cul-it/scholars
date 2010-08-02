<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#import "/lib/list.ftl" as l>

<div id="footer">

    <#if bannerImageUrl??>
        <img class="footerLogo" src="${urls.bannerImage}" alt="${tagline!}" />
    </#if>
    
    <p class="siteFeedback">
      <#if urls.contact??>
          <a href="${urls.contact}">Contact Us</a>
      </#if>
    </p>
    
    <#include "copyright.ftl">

    All Rights Reserved. <a href="${urls.termsOfUse}">Terms of Use</a>

</div><!-- footer -->

