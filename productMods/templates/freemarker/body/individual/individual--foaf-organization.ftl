<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->

<#if temporalVisualizationEnabled>
    <#assign classSpecificExtension>
        <section id="right-hand-column" role="region">
            <#include "individual-visualizationTemporalGraph.ftl">
            <#include "individual-visualizationMapOfScience.ftl">
        </section> <!-- #right-hand-column -->
    </#assign>
</#if>

<#assign affiliatedResearchAreas>
    <#include "individual-affiliated-research-areas.ftl">
</#assign>

<#if individual.mostSpecificTypes?seq_contains("Academic Department") >
    <#if getGrantResults?has_content >
        <#assign departmentalGrantsExtension>    
            <div id="activeGrantsLink">
                <img src="${urls.base}/images/individual/arrow-green.gif">
                <a href="${urls.base}/deptGrants?individualURI=${individual.uri}" title="${i18n().view_all_active_grants}">
                    ${i18n().view_all_active_grants}
                </a>    
            </div>
        </#assign>
    </#if>
</#if>
<#if individual.mostSpecificTypes?seq_contains("Academic Department")  || individual.mostSpecificTypes?seq_contains("Graduate Field/Program") >
<#assign departmentalGraduateFields>
    <div id="gradFieldsContainer" style="display:none">
        <#include "individual-dept-graduate-fields.ftl">
    </div>
    <script>
        $('section#share-contact').append($('div#gradFieldsContainer').html());
    </script>
</#assign>
</#if>
<!-- yo, dude: ${individual.mostSpecificTypes} -->

<#include "individual.ftl">

