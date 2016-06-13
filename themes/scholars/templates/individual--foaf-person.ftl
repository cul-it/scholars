<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Person individuals -->

<script>
$(document).ready(function() {
});
</script>

<!--[if IE 7]>
<link rel="stylesheet" href="${urls.base}/css/individual/ie7-standard-view.css" />
<![endif]-->
<#include "individual-setup.ftl">
<#import "individual-qrCodeGenerator.ftl" as qr>
<#import "lib-vivo-properties.ftl" as vp>
<#--Number of labels present-->
<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>
<#assign nameForOtherGroup = "${i18n().other}">
<#--Number of available locales-->
<#if !localesCount??>
	<#assign localesCount = 1>
</#if>
<#--Number of distinct languages represented, with no language tag counting as a language, across labels-->
<#if !languageCount??>
	<#assign languageCount = 1>
</#if>	
<#assign emailProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#Email")!>
<#assign email = "" />
<#if emailProp?has_content && emailProp.statements?has_content>
	<#assign email = emailProp.statements?first/>
</#if>
<#assign visRequestingTemplate = "foaf-person-2column">
<#assign publicationsProp = propertyGroups.pullProperty("${core}relatedBy", "${core}Authorship")!>
<#if publicationsProp?has_content> 
    <#assign publications>
		<@p.objectProperty publicationsProp editable />
	</#assign>
</#if>
<#assign grantsPIProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/RO_0000053", "${core}PrincipalInvestigatorRole")!>
<#if grantsPIProp?has_content> 
    <#assign grantsPI>
		<@p.objectProperty grantsPIProp editable />
	</#assign>
</#if>
<#assign grantsCOPIProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/RO_0000053", "${core}CoPrincipalInvestigatorRole")!>
<#if grantsCOPIProp?has_content> 
    <#assign grantsCOPI>
		<@p.objectProperty grantsCOPIProp editable />
	</#assign>
</#if>
<#if subjectAreas?has_content>
  <#assign subjectAreaList>
	<article class="property" role="article">
		<ul id="individual-publications" class="property-list" role="list">
			<#list subjectAreas as subject>
				<li role="listitem">		
					<a href="${urls.base}/individual?uri=${subject.subjectArea!}">${subject.subjectAreaLabel!}</a>
				</li>
			</#list>
		</ul>
	</article>
  </#assign>
</#if>

<#--add the VIVO-ORCID interface -->
<#include "individual-orcidInterface.ftl">  
<div id="row1" class="row" style="background-color:#f1f2f3">
<div class="col-sm-12 col-md-12 col-lg-12" id="foafPersonMainColumn" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
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
    
    <#-- include "individual-visualizationFoafPerson.ftl" -->
</section> <!-- end share-contact -->
<section id="individual-info" ${infoClass!} role="region" style="padding-bottom: 15px;">
    <#include "individual-adminPanel.ftl">
    <header>
        <#if relatedSubject??>
            <h2>${relatedSubject.relatingPredicateDomainPublic} ${i18n().for} ${relatedSubject.name}</h2>
            <p><a href="${relatedSubject.url}" title="${i18n().return_to(relatedSubject.name)}">&larr; ${i18n().return_to(relatedSubject.name)}</a></p>
        <#else>  
            <h1 itemprop="name" class="vcard foaf-person fn" style="margin-top:10px;<#if !editable>float:left;</#if>"> 
                <#-- Label -->
                <@p.label individual editable labelCount localesCount/>
            </h1>
        </#if>    
		<div style="float:right;margin:6px 4px -14px 0">
			<#include "individual-iconControls.ftl" />
		</div>
    	<#include "individual-positions.ftl">
    </header>
	</section>
</div> <!-- foafPersonMainColumn -->
</div> <!-- row1 -->


<#-- include "individual-visualizationFoafPerson.ftl" -->
<div id="row2" class="row" style="background-color:#f1f2f3;margin-top:30px" >

<div id="foafPersonViz" class="col-sm-3 col-md-3 col-lg-3" style=";border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
	<h4 style="display:none;color:#5f5858;text-align:center;margin-top:16px;margin-bottom:16px;font-size:1.6em;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Visualizations</h4>
	<div style="text-align:center">
		<p style="margin-top:16px;margin-bottom:2px;padding-top:6px;font-size:16px"><a href="#">Keywords</a></p>
		<img width="70%" src="collaborations.png"/>
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
	<div id="tabs" style="margin: 0 -15px 0 -15px;padding:0">
	  <ul style="margin:0;padding:8px 0 0 8px; border-top:none;border-right: none; border-left:none; background:#ebf3f4;border-radius:0">
	    <#if publications?has_content && publications?contains("article")><li><a href="#tabs-1">Publications</a></li></#if><#-- e2effa -->
	    <#if grantsPI?has_content || grantsCOPI?has_content><li><a href="#tabs-2">Grants</a></li></#if>
	    <#if subjectAreaList?has_content><li><a href="#tabs-3">Subject Areas</a></li></#if>
	  </ul>
	  <#if publications?has_content && publications?contains("article")>
		  <div id="tabs-1" style="height:620px;overflow:auto" data="${publicationsProp!}-dude">
			<article class="property" role="article">
		    <ul id="individual-publications" class="property-list" role="list" >
		    	${publications!}
			</ul>
			</article>	
		  </div>
	  </#if>
	  <#if grantsPI?has_content || grantsCOPI?has_content>
		  <div id="tabs-2" style="height:620px;overflow:auto">
		    <article class="property" role="article">
		    <ul id="individual-grants-pi" class="property-list" role="list" >
				<li class="subclass" role="listitem">
				  <#if grantsPI?has_content >
					<h3>Principal Investigator</h3>
				    <ul class="subclass-property-list">
		    			${grantsPI!}
					</ul>
				  </#if>
				  <#if grantsCOPI?has_content >
					<h3>Co-principal Investigator</h3>
				    <ul class="subclass-property-list">
		    			${grantsCOPI!}
					</ul>
				  </#if>
				</li>
			</ul>
			</article>
		  </div>
	  </#if>
	  <#if subjectAreaList?has_content>
		  <div id="tabs-3" style="height:620px;overflow:auto;margin:16px 0 0 16px">
		    ${subjectAreaList}
		  </div>
	  </#if>
	</div>
</div> <!-- row2 div -->
<#-- <#include "individual-property-group-tabs.ftl"> -->
</div>
<#if !editable>
<script>
    var title = $('div#titleContainer').width();
    var name = $('h1.vcard').width();
    var total = parseInt(title,10) + parseInt(name,10);
    if ( name < 280 && total > 600 ) {
        var diff = total - 600;
        $('div#titleContainer').width(title - diff);
    }
    else if ( name > 279 && name + title > 600 ) {
        $('div#titleContainer').width('620');
    }
</script>
</#if>
<script>
    var imagesPath = '${urls.images}';
</script>
<#assign rdfUrl = individual.rdfUrl>

<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>
<script type="text/javascript">
var individualUri = '${individual.uri!}';
var individualPhoto = '${individual.thumbNail!}';
var exportQrCodeUrl = '${urls.base}/qrcode?uri=${individual.uri!}';
var baseUrl = '${urls.base}';
var profileTypeData = {
    processingUrl: '${urls.base}/edit/primitiveRdfEdit',
    individualUri: '${individual.uri!}',
    defaultProfileType: '${profileType!}'
};
var i18nStrings = {
    errorProcessingTypeChange: '${i18n().error_processing_type_change}',
    displayLess: '${i18n().display_less}',
    displayMoreEllipsis: '${i18n().display_more_ellipsis}',
    showMoreContent: '${i18n().show_more_content}',
    verboseTurnOff: '${i18n().verbose_turn_off}',
    standardviewTooltipOne: '${i18n().standardview_tooltip_one}',
    standardviewTooltipTwo: '${i18n().standardview_tooltip_two}',
    researchAreaTooltipOne: '${i18n().research_area_tooltip_one}',
    researchAreaTooltipTwo: '${i18n().research_area_tooltip_two}'
};
var i18nStringsUriRdf = {
    shareProfileUri: '${i18n().share_profile_uri}',
    viewRDFProfile: '${i18n().view_profile_in_rdf}',
    closeString: '${i18n().close}'
};
</script>
<script>
$(function() {
  $( "#tabs" ).tabs();
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-2column-view.css" />',
                  '<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualQtipBubble.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualProfilePageType.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>')}



<!-- ------------ -->
