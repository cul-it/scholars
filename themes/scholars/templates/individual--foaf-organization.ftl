<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->

<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

<#assign individualProductExtension>
    <#-- Include for any class specific template additions -->
    ${classSpecificExtension!}
    ${departmentalGrantsExtension!} 
    <!--PREINDIVIDUAL OVERVIEW.FTL-->
    <#include "individual-webpage.ftl">
    <#include "individual-overview.ftl">
    ${affiliatedResearchAreas!}
	${graduateFieldDepartments!}
        </section> <!-- #individual-info -->
    </section> <!-- #individual-intro -->
    <!--postindividual overview ftl-->
    ${departmentalGraduateFields!}
</#assign>
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
	<#assign departmentalGraduateFields>
	    <div id="gradFieldsContainer" style="display:none">
	        <#include "individual-dept-graduate-fields.ftl">
	    </div>
	    <script>
	        $('section#share-contact').append($('div#gradFieldsContainer').html());
	    </script>
	</#assign>
</#if>
<#if individual.mostSpecificTypes?seq_contains("Graduate Field/Program") >
	<#assign graduateFieldDepartments>
    	<#include "individual-dept-graduate-fields.ftl">
	</#assign>
</#if>

<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<#import "lib-microformats.ftl" as mf>

<#--Number of labels present-->
<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>
<#--Number of available locales-->
<#if !localesCount??>
	<#assign localesCount = 1>
</#if>
<#--Number of distinct languages represented, with no language tag counting as a language, across labels-->
<#if !languageCount??>
	<#assign languageCount = 1>
</#if>	

<#-- Default individual profile page template -->
<div id="row1" class="row" style="background-color:#f1f2f3">
<div class="col-sm-12 col-md-12 col-lg-12" id="foafOrgMainColumn" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
	<section id="share-contact" role="region"> 
	    <#-- Image -->           
	    <#assign individualImage>
	        <@p.image individual=individual 
	                  propertyGroups=propertyGroups 
	                  namespaces=namespaces 
	                  editable=editable 
	                  showPlaceholder="always" />
	    </#assign>
	
	    <#if ( individualImage?contains('<img class="individual-photo"') )>
	        <#assign infoClass = 'class="withThumb"'/>
	    </#if>
	
	    <div id="photo-wrapper" >${individualImage}</div>
	</section> <!-- end share-contact -->
	<section id="individual-info" ${infoClass!} role="region">
	    <#include "individual-adminPanel.ftl">

	    <#if individualProductExtensionPreHeader??>
	        ${individualProductExtensionPreHeader}
	    </#if>

	    <header>
	        <#if relatedSubject??>
	            <h2>${relatedSubject.relatingPredicateDomainPublic} for ${relatedSubject.name}</h2>
	            <p><a href="${relatedSubject.url}" title="${i18n().return_to(relatedSubject.name)}">&larr; ${i18n().return_to(relatedSubject.name)}</a></p>                
	        <#else>                
	            <h1 class="fn" itemprop="name" style="margin-top:17px;float:left;">
	                <#-- Label -->
	                <@p.label individual editable labelCount localesCount languageCount/>
	                <#--  Most-specific types -->
	                <@p.mostSpecificTypes individual />
	                <span id="iconControlsVitro"><img id="uriIcon" title="${individual.uri}" class="middle" src="${urls.images}/individual/uriIcon.gif" alt="uri icon"/></span>
	            </h1>
	        </#if>
	    </header>

	        </section> <!-- individual-info -->
			<div style="clear:both"></div>
	</div> <!-- foafPersonMainColumn -->
</div> <!-- row1 -->

<#assign nameForOtherGroup = "${i18n().other}"> 

<div id="row2" class="row" style="background-color:#f1f2f3;margin-top:30px" >

<div id="foafOrgViz" class="col-sm-3 col-md-3 col-lg-3" style=";border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
	<h4 style="color:#5f5858;text-align:center;margin-top:16px;margin-bottom:16px;font-size:20px;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Visualizations</h4>
	<div style="text-align:center">
		<img width="70%" src="collaborations.png"/>
		<p style="padding-top:6px"><a href="#">Collaborations</a></p>
	</div>
	<div style="text-align:center;padding-top:16px">
		<img width="70%" src="affiliations.png"/>
		<p style="padding-top:6px"><a href="#">Affiliations</a></p>
	</div>
	<div style="text-align:center;padding-top:16px">
		<img width="70%" src="research-areas.png"/>
		<p style="padding-top:6px"><a href="#">Research Areas</a></p>
	</div>
	<div style="text-align:center;padding-top:16px">
		<img width="70%" src="co-authors.png"/>
		<p style="padding-top:6px"><a href="#">Co-author Networks</a></p>
	</div>
</div>
<div id="foafPersonSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
<div id="foafPersonTabs" class="col-sm-8 col-md-8 col-lg-8" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;background-color: #fff">

<#include "individual-property-group-tabs.ftl">
</div>
</div> <!-- row2 div -->

<#assign rdfUrl = individual.rdfUrl>

<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>
<script>
    var i18nStringsUriRdf = {
        shareProfileUri: '${i18n().share_profile_uri}',
        viewRDFProfile: '${i18n().view_profile_in_rdf}',
        closeString: '${i18n().close}'
    };
	var i18nStrings = {
	    displayLess: '${i18n().display_less}',
	    displayMoreEllipsis: '${i18n().display_more_ellipsis}',
	    showMoreContent: '${i18n().show_more_content}',
	};

</script>
<script>
    var individualLocalName = "${individual.localName}";
</script>
<script>
var i18nStrings = {
    displayLess: '${i18n().display_less}',
    displayMoreEllipsis: '${i18n().display_more_ellipsis}',
    showMoreContent: '${i18n().show_more_content}',
    verboseTurnOff: '${i18n().verbose_turn_off}',
};
var i18nStringsUriRdf = {
    shareProfileUri: '${i18n().share_profile_uri}',
    viewRDFProfile: '${i18n().view_profile_in_rdf}',
    closeString: '${i18n().close}'
};

</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>')}


${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}

<script type="text/javascript">
    i18n_confirmDelete = "${i18n().confirm_delete}"
</script>
