<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "menupage-checkForData.ftl">

<div class="row"  style="background-color:#fff;">
<div id="container" class="col-sm-12 col-md-12 col-lg-12" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2 style="font-size:20px;color:rgb(95, 88, 88)">${page.title}</h2>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>
  </div> <!--! end of #container -->
</div> <!-- end of row -->
