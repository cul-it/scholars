<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "menupage-checkForData.ftl">

<div class="row fff-bkg">
<div id="menupage-container" class="col-sm-12 col-md-12 col-lg-12 scholars-container">

<#if !noData>
        <h2 class="expertsResultsHeader">${page.title}</h2>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>
  </div> <!--! end of #container -->
</div> <!-- end of row -->
