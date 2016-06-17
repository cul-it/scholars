<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->
<style>
#visualizationTarget {
	display: none;
}
</style>
<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

<#assign individualProductExtension>
    <#-- Include for any class specific template additions -->
    ${classSpecificExtension!}
    ${departmentalGrantsExtension!} 
    <!--PREINDIVIDUAL OVERVIEW.FTL-->
    <#-- include "individual-webpage.ftl" -->
    <#include "individual-overview.ftl">
    ${affiliatedResearchAreas!}
	${graduateFieldDepartments!}
        </section> <!-- #individual-info -->
    </section> <!-- #individual-intro -->
    <!--postindividual overview ftl-->
    ${departmentalGraduateFields!}
</#assign>
<#assign isAcademicDept = false />
<#if individual.mostSpecificTypes?seq_contains("Academic Department") >
	<#assign isAcademicDept = true />
</#if>
<#assign isCollege = false />
<#if individual.mostSpecificTypes?seq_contains("College") >
	<#assign isCollege = true />
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
<#assign awardsGrantProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#assigns", "${core}Grant")!>
<#if awardsGrantProp?has_content> 
    <#assign awardsGrant>
		<@p.objectProperty awardsGrantProp editable />
	</#assign>
</#if>
<#assign adminsGrantProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/RO_0000053", "${core}AdministratorRole")!>
<#if adminsGrantProp?has_content> 
    <#assign adminsGrant>
		<@p.objectProperty adminsGrantProp editable />
	</#assign>
</#if>
<#assign facultyProp = propertyGroups.pullProperty("${core}relatedBy", "${core}Position")!>
<#if facultyProp?has_content> 
    <#assign facultyList>
		<@p.objectProperty facultyProp editable />
	</#assign>
</#if>
<#if academicOfficers?has_content>
  <#assign academicOfficerList>
		<div style="margin:6px 0 15px 0">
		<#list academicOfficers as officer>
			<div style="margin-top:6px;color:#CC6949;font-size:16px;text-align:right;display:inline-block">
				${officer.positionTitle!}
			</div>
			<div  style="margin-top:6px;color:#595b5b;font-size:16px;padding-left:8px;display:inline-block">
				${officer.personName!}
			</div>
			<div style="clear:both"></div>
		</#list>
		</div>
  </#assign>
</#if>
<#assign webpageProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#URL")!>
<#if webpageProp?has_content && webpageProp.statements?has_content> 
    <#assign webpageStmt = webpageProp.statements?first />
	<#assign webpageLabel = webpageStmt.label! />
	<#assign webpageUrl = webpageStmt.url! />
</#if>
<#if isCollege>
	<#assign departmentsProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/BFO_0000051","http://xmlns.com/foaf/0.1/Organization")!>
	<#if departmentsProp?has_content && departmentsProp.statements?has_content> 
	    <#assign subOrgs>
			<@p.objectProperty departmentsProp editable />
		</#assign>
	</#if>
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
	            </h1>
	        </#if>
			<div style="float:right;margin:12px 4px -14px 0">
				<#include "individual-iconControls.ftl" />
			</div>
			<h2 id="relatedBy" class="mainPropGroup" title="A position, either vertical or horizontal." style="margin-right:-24px;clear:both;padding-top:0;border-bottom:1px solid #b9b9b9">  </h2>
	    </header>
		<div style="clear:both"></div>
		${academicOfficerList!}
	 </section> <!-- individual-info -->
			<div style="clear:both"></div>
	</div> <!-- foafPersonMainColumn -->
</div> <!-- row1 -->

<#assign nameForOtherGroup = "${i18n().other}"> 

<div id="row2" class="row" style="background-color:#f1f2f3;margin-top:30px" >

<div id="foafOrgViz" class="col-sm-3 col-md-3 col-lg-3" style=";border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
<#if nameForOtherGroup?has_content >
	<#if nameForOtherGroup?has_content >
		<div style="text-align:center;padding-top:34px;">
		  <#if isAcademicDept >
			<a href="#" id="view_selection" class="jqModal" ><img width="40%" src="${urls.base}/themes/scholars/images/dept_grants.png"/></a>
		  <#elseif isCollege >
				<img width="40%" src="${urls.base}/themes/scholars/images/dept_grants.png"/>
		  </#if>
			<p style="padding-top:8px;font-size:16px;color:#CC6949">Grants</p>
		</div>
	</#if>
	<div style="text-align:center;padding-top:26px">
	  <#if isAcademicDept >
			<a href="${urls.base}/orgSAVisualization?deptURI=${individual.uri}"><img width="68%" src="${urls.base}/themes/scholars/images/person_sa.png"/></a>
			<p style="padding-top:4px;font-size:16px;color:#CC6949">Subject Areas</p>
	  <#elseif isCollege >
			<a id="collaborations_trigger" href="#"><img width="54%" src="${urls.base}/themes/scholars/images/collab2.png"/></a>
			<p style="padding-top:4px;font-size:16px;color:#CC6949">Collaborations</p>
	  </#if>
	</div>
</#if>
</div>
<div id="foafOrgSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
<#if isAcademicDept >
<div id="foafOrgTabs" class="col-sm-8 col-md-8 col-lg-8" style="<#if facultyList?has_content || adminsGrant?has_content >border: 1px solid #cdd4e7;border-top:5px solid #CC6949;background-color: #fff</#if>">
  <#if facultyList?has_content || adminsGrant?has_content >
	<div id="tabs" style="margin: 0 -15px 0 -15px;padding:0">
	  <ul style="margin:0;padding:8px 0 0 8px; border-top:none;border-right: none; border-left:none; background:#ebf3f4;border-radius:0">
	    <#if facultyList?has_content ><li><a href="#tabs-1">People</a></li> </#if>
	    <#if adminsGrant?has_content ><li><a href="#tabs-2">Grants</a></li></#if>
	  </ul>
	  <#if facultyList?has_content >
		  <div id="tabs-1" style="height:620px;overflow:auto" data="${publicationsProp!}-dude">
			<article class="property" role="article">
		    <ul id="individual-faculty" class="property-list" role="list" >
		    	${facultyList?replace(" position","")!}
			</ul>
			</article>	
		  </div>
	  </#if>
	  <#if adminsGrant?has_content || awardsGrant?has_content >
		  <div id="tabs-2" style="height:620px;overflow:auto">
			<article class="property" role="article">
		    <ul id="individual-grants-pi" class="property-list" role="list" >
				<li class="subclass" role="listitem">
				  <#if adminsGrant?has_content >
					<h3>Administers Grant</h3>
				    <ul class="subclass-property-list">
		    			${adminsGrant!}
					</ul>
				  </#if>
				  <#if awardsGrant?has_content >
					<h3>Awards Grant</h3>
				    <ul class="subclass-property-list">
		    			${awardsGrant!}
					</ul>
				  </#if>
				</li>
			</ul>
		    
		  </div>
	  </#if>
	</div>
  </#if>
</div>
</#if>
<#if isCollege && subOrgs?has_content >
<div id="foafOrgTabs" class="col-sm-8 col-md-8 col-lg-8" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;background-color: #fff">
	<div id="tabs" style="margin: 0 -15px 0 -15px;padding:0">
	  <ul style="margin:0;padding:8px 0 0 8px; border-top:none;border-right: none; border-left:none; background:#ebf3f4;border-radius:0">
	    <li><a href="#tabs-1">Departments</a></li>
	  </ul>
		  <div id="tabs-1" style="height:620px;overflow:auto" data="${publicationsProp!}-dude">
			<article class="property" role="article">
		    <ul id="individual-faculty" class="property-list" role="list" style="margin-top:16px">
		    	${subOrgs!}
			</ul>
			</article>	
		  </div>
	</div>
</div>
</#if>
</div> <!-- row2 div subOrgs -->
<#if !facultyList?has_content || !adminsGrant?has_content >
	<div style="height:200px;min-height:200px"></div>
</#if>

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
	$(function() {
	  $( "#tabs" ).tabs();
	});
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
<script>
$().ready(function() {
	if ($('#individual-faculty li').first().children('h3').text() == "academic officer") {
		$('#individual-faculty li').first().hide();
	}
});
</script>
<div class="jqmWindow" id="dialog" style="border-radius:5px;padding:7px 12px 3px 12px">
	<div id="vis" style="background-color:#fff"></div>
</div>





<script>
$().ready(function() {
  $('#dialog').jqm({
	onHide: function(hash){
	    // hide modal
	    hash.w.hide();
	    // clear content
		$('#gates_tooltip').css("display","none");
	    // remove overlay
	    hash.o.remove();
	}
  });
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>')}


${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
				    '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
					'<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
                  	'<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}

<script type="text/javascript">
    i18n_confirmDelete = "${i18n().confirm_delete}"
</script>
<script>
	grantsDataDepartmentUri = "${individual.uri}"
</script>


${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
					'<link rel="stylesheet" href="${urls.base}/css/scholars-vis/grants/style.css" />',
					'<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}

<#if isCollege >
	${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/collaborations/collab.css" />')}
</#if>
${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/transform-data.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/plugins.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/script.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/CustomTooltip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/coffee-script.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/papaparse.min.js"></script>',
			'<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
			'<script type="text/javascript" src="${urls.base}/js/scholars-vis/collaborations/collaborations.js"></script>',
			'<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
			'<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/coffeescript" src="${urls.base}/js/scholars-vis/grants/vis-modal.coffee"></script>')}



		


<script type="text/javascript">
  $(document).ready(function() {
        $('#view_selection_off').click(function() {
		  // $('#vis').show();
          var view_type = 'years'//$(this).children(":selected").attr('id');
          toggle_view(view_type);
          return false;
        });
  });
</script>
<div id="collab_vis" style="height:600;z-index:15;border-radius:5px"></div>
<#if isCollege >
	<script>
	$().ready(function() {
	  loadVisualization({
    	modal : true, 
	    target : '#collab_vis',
	    trigger : '#collaborations_trigger',
	    url : "${urls.base}/api/dataRequest?action=collaboration_sunburst",
	    transform : transformCollab,
	    display : sunburst,
	    height : 500,
	    width : 700	  });
	});
	</script>
</#if>
