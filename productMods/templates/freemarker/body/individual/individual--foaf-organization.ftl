<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->
<#if temporalVisualizationEnabled>
    <#assign classSpecificExtension>
        <section id="visualization" role="region">
            <#include "individual-visualizationTemporalGraph.ftl">
            <#include "individual-visualizationMapOfScience.ftl">
        </section> <!-- #visualization-org -->
    </#assign>
</#if>

<#include "individual.ftl">

<script>
// kind of a hack - but if it's edit mode AND the organization has no photo AND there's more than
// one webpage, modify the css to get a decent layout.
<#if !editable >
    if ( $('div#photo-wrapper').children().length == 0 ) {
        $('ul.webpages-withThumbnails li:first-child').find('img.org-webThumbnail').css('margin-right', '10px');
        $('ul.webpages-withThumbnails li:first-child').find('a.weblink-icon').css('margin-left', '-242px');
        $('ul.webpages-withThumbnails li:nth-child(2)').find('img.org-webThumbnail').css('margin-top', '106px');
        $('ul.webpages-withThumbnails li:nth-child(2)').find('a.weblink-icon').css('margin-top', '166px');
    }
</#if>
</script>
