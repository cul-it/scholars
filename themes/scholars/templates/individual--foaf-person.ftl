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
<#assign isAuthor = p.hasVisualizationStatements(propertyGroups, "${core}relatedBy", "${core}Authorship") />
<#assign coAuthorVisUrl = individual.coAuthorVisUrl()>
<#assign obo_RO53 = "http://purl.obolibrary.org/obo/RO_0000053">
<#assign isInvestigator = ( p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}InvestigatorRole") ||
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}PrincipalInvestigatorRole") || 
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}CoPrincipalInvestigatorRole") ) >
<#assign coInvestigatorVisUrl = individual.coInvestigatorVisUrl()>
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
		<h3 style="color: rgb(204, 105, 73);">Journal Subject Areas</h3>
		<ul id="individual-publications" class="property-list" role="list" style="padding-top:12px">
			<#list subjectAreas as subject>
				<li role="listitem">		
					<a href="${urls.base}/individual?uri=${subject.subjectArea!}">${subject.subjectAreaLabel!}</a>
				</li>
			</#list>
		</ul>
	</article>
  </#assign>
</#if>
<#assign hasKeywords = false />
<#if keywords?has_content>
  <#assign hasKeywords = true />
</#if>
<#assign webpageProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#URL")!>
<#if webpageProp?has_content && webpageProp.statements?has_content> 
    <#assign webpageStmt = webpageProp.statements?first />
	<#assign webpageLabel = webpageStmt.label! />
	<#assign webpageUrl = webpageStmt.url! />
</#if>
<#-- for some reason pullProperty was only working when logged in, and even with the display level set to public. Weird! So using datagetter-->
<#if orcidID?has_content> 
	<#assign theOrcidId = orcidID?first.orcidId! />
</#if>

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


<#if isAuthor || isInvestigator || editable >
<div id="row2" class="row" style="background-color:#f1f2f3;margin:30px -15px 100px -15px" >

<div id="foafPersonViz" class="col-sm-3 col-md-3 col-lg-3" style=";border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
	<h4 style="display:none;color:#5f5858;text-align:center;margin-top:16px;margin-bottom:16px;font-size:1.6em;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Visualizations</h4>
 	<#if isAuthor >
		<#if hasKeywords >
 			<div style="text-align:center;padding-top:34px;">
 				<a href="#" id="word_cloud_trigger"><div id="dynamic_word_cloud" style="height:120px;display:inline">&nbsp;</div></a>
 				<p style="padding-top:8px;font-size:16px;color:#CC6949">Keywords</p>
 			</div>
		</#if>
 		<div style="text-align:center;padding-top:26px">
 			<a href="${coAuthorVisUrl}"><img width="60%" src="${urls.base}/themes/scholars/images/co-authors.png"/></a>
 			<p style="padding-top:4px;font-size:16px;color:#CC6949">Co-authors</p>
 		</div>
 	</#if>
 	<#if isInvestigator >
 		<div style="text-align:center;padding-top:26px">
 			<a href="${coInvestigatorVisUrl}"><img width="60%" src="${urls.base}/themes/scholars/images/co-investigators.png"/></a>
 			<p style="padding-top:4px;font-size:16px;color:#CC6949">Co-investigators</p>
 		</div>
 	</#if>
</div>
<div id="foafPersonSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
<div id="foafPersonTabs" class="col-sm-8 col-md-8 col-lg-8" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;background-color: #fff">
	<div id="tabs" style="margin: 0 -15px 0 -15px;padding:0">
	  <ul style="margin:0;padding:8px 0 0 8px; border-top:none;border-right: none; border-left:none; background:#ebf3f4;border-radius:0">
	    <#if isAuthor ><li><a href="#tabs-1">Publications</a></li></#if>
	    <#if isInvestigator ><li><a href="#tabs-2">Grants</a></li></#if>
	  </ul>
	  <#if isAuthor >
		  <div id="tabs-1" style="height:620px;overflow:auto">
			<article class="property" role="article">
			<#if subjectAreaList?has_content>
				<a href="#" class="jqModal" style="color:#167093;float:right;padding-right:18px;margin-top:6px">Subject Areas</a>
			</#if>
		    <ul id="individual-publications" class="property-list" role="list" >
		    	${publications!}
			</ul>
			</article>	
		  </div>
	  </#if>
	  <#if isInvestigator >
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
	</div>
</div>
</div> <!-- row2 div -->
<#else>
<div class="row" style="margin-bottom:400px"></div>
</#if>
<div id="person_word_cloud" style="padding:13px 0 0 22px;z-index:3;border-radius:5px"></div>

<#-- <#include "individual-property-group-tabs.ftl"> -->



<div class="jqmWindow" id="dialog" style="padding:0;border-radius:3px;border-color:#f1f2f3;max-height:480px;overflow:auto">
	<div style="background-color:#fff">
		<a href="#" class="jqmClose" style="float:right;padding-right:15px;margin-top:7px"><i class="fa fa-times" aria-hidden="true"></i>
		</a>
		${subjectAreaList!}
	</div>
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
$().ready(function() {
  $('#dialog').jqm();
});
</script>
<#if hasKeywords >
	<script>
	$().ready(function() {
	  loadVisualization({
	    modal : true, 
	    target : '#person_word_cloud',
	    trigger : '#word_cloud_trigger',
	    url : "${urls.base}/api/dataRequest?action=person_word_cloud&person=${individual.uri?url}",
	    parse : 'turtle',
	    transform : transform_word_cloud_data,
	    display : draw_word_cloud,
	    height : 0.70,
	    width : 0.70
	  });
	});
	$().ready(function() {
	  loadVisualization({
	//    modal : true, 
	    target : '#dynamic_word_cloud',
	//    trigger : '#word_cloud_trigger',
	    url : "${urls.base}/api/dataRequest?action=person_word_cloud&person=${individual.uri?url}",
	    parse : 'turtle',
	    transform : iconize_word_cloud_data,
	    display : draw_iconized_word_cloud,
	    height : 120,
	    width : 220
	  });
	});
	</script>
</#if>
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

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/iconized-person-word-cloud.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/person-word-cloud.js"></script>')}

${stylesheets.add('<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	'<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

