<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)

-->
<#-- Do not show the link for temporal visualization unless it's enabled -->
<#if temporalVisualizationEnabled>
    <#assign classSpecificExtension>
<#--        <section id="visualization" role="region">
            <#include "individual-visualizationTemporalGraph.ftl">
            <#include "individual-visualizationMapOfScience.ftl">
        </section> --> <!-- #visualization-org -->
    </#assign>
</#if>

<#include "individual.ftl">

<script>
<#-- 
      Academic Departments have a "view active grants link" and the css is geared to this. For other orgs,
      adjust the margins to get the correct layout.
 -->
if (!$('div#activeGrantsLink').length > 0) {
    $('ul.webpages-withThumbnails li:nth-child(2)').find('img.org-webThumbnail').css('margin-top', '49px');
    $('ul.webpages-withThumbnails li:nth-child(2)').find('a.weblink-icon').css('margin-top', '109px');
}

</script>
