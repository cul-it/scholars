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
<#import "lib-microformats.ftl" as mf>

<#assign isAcademicDept = false />
<#if individual.mostSpecificTypes?seq_contains("Academic Department") >
	<#assign isAcademicDept = true />
</#if>
<#assign isCollege = false />
<#if individual.mostSpecificTypes?seq_contains("College") >
	<#assign isCollege = true />
</#if>
<#assign isCollegeOrSchool = false />
<#if individual.mostSpecificTypes?seq_contains("College") || individual.mostSpecificTypes?seq_contains("School") || individual.mostSpecificTypes?seq_contains("Administrative Unit")>
	<#assign isCollegeOrSchool = true />
</#if>
<#assign isJohnsonOrHotelSchool = false />
<#if individual.name?contains(" Johnson Graduate School") || individual.name?contains("Hotel Administration")>
	<#assign isJohnsonOrHotelSchool = true />
</#if>
<#assign isInstitute = false />
<#if individual.mostSpecificTypes?seq_contains("Institute")>
	<#assign isInstitute = true />
</#if>
<#assign showVisualizations = false>
<#if individual.mostSpecificTypes?seq_contains("College") || individual.mostSpecificTypes?seq_contains("School") || individual.mostSpecificTypes?seq_contains("Academic Department")>
	<#assign showVisualizations = true />
</#if>

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
<#-- 
	When logged in, "adminsGrantProp?has_content" returns true even though there are no grants. Same for
	"awardsGrantProp?has_content". As a result adminsGrant and awardsGrant will have content that is only 
	whitespace. This boolean is used to prevent an empty Grants tab from displaying.
-->
<#assign showGrantsTab = false />
<#if awardsGrant?has_content || adminsGrant?has_content>
	<#if (awardsGrant?has_content && (awardsGrant?string?replace(" ","")?replace("\n","")?length > 0)) || (adminsGrant?has_content  && (adminsGrant?string?replace(" ","")?replace("\n","")?length > 0))>
		<#assign showGrantsTab = true />
	</#if>
</#if>
<#assign facultyProp = propertyGroups.pullProperty("http://scholars.cornell.edu/ontology/hr.owl#hasPosition", "${core}Position")!>
<#if facultyProp?has_content > 
    <#assign facultyList>
		<@p.objectProperty facultyProp editable />
	</#assign>
</#if>
<#-- 
	When logged in, "facultyProp?has_content" returns true even though there are no faculty members, and
	as a result facultyList will have content that is only whitespace. This boolean is used to prevent
	an empty People tab from displaying.
-->
<#assign showPeopleTab = false />
<#if facultyList?has_content >
	<#if (facultyList?string?replace(" ","")?replace("\n","")?length > 0) >
		<#assign showPeopleTab = true />
	</#if>
</#if>
<#assign affiliationProp = propertyGroups.pullProperty("${core}relatedBy", "http://scholars.cornell.edu/ontology/vivoc.owl#Affiliation")!>
<#if affiliationProp?has_content && affiliationProp.statements??> 
    <#assign affiliationList>
		<@p.objectProperty affiliationProp editable />
	</#assign>
</#if>
<#-- 
	When logged in, "affiliationProp?has_content" returns true even though there are no affiliated people, 
	and as a result facultyList will have content that is only whitespace. This boolean is used to prevent
	an empty People tab from displaying.
-->
<#if affiliationList?has_content >	
	<#if (affiliationList?string?replace(" ","")?replace("\n","")?length > 0) >
		<#assign showPeopleTab = true />
	</#if>
</#if>
<#if academicOfficers?has_content>
  <#assign academicOfficerList>
		<#list academicOfficers as officer>
			<div id="academic-officer-list-title">
				${officer.positionTitle!}
			</div>
			<div id="academic-officer-list-name">
				${officer.personName!}
			</div>
			<div class="clear-both"></div>
		</#list>
  </#assign>
</#if>
<#assign webpageProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#URL")!>
<#if webpageProp?has_content && webpageProp.statements?has_content> 
    <#assign webpageStmt = webpageProp.statements?first />
	<#assign webpageLabel = webpageStmt.label! />
	<#assign webpageUrl = webpageStmt.url! />
</#if>
<#if isCollegeOrSchool>
	<#assign departmentsProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/BFO_0000051","http://xmlns.com/foaf/0.1/Organization")!>
	<#if departmentsProp?has_content && departmentsProp.statements?has_content> 
	    <#assign subOrgs>
			<@p.objectProperty departmentsProp editable />
		</#assign>
	</#if>
</#if>

<#assign visualizationColumn >
  <#if isAcademicDept || isCollegeOrSchool >
  	<div id="visualization-column" class="col-sm-3 col-md-3 col-lg-3 scholars-container">
  </#if>
  <#if isAcademicDept || isJohnsonOrHotelSchool >
	<div id="word_cloud_icon_holder" style="display:none">
		<a href="#" id="word_cloud_trigger" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Department-School', 'Research-Keywords']);">
			<img id="vizIcon" width="145px" src="${urls.base}/themes/scholars/images/wordcloud-icon.png"/>
		</a>
		<p>Keyword Cloud</p>
	</div>
	<div>
		<a href="${urls.base}/oneOrganizationSubjectAreaVisualization?deptURI=${individual.uri?url}&deptLabel=${individual.name?url}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Department-School', 'Research-Interests']);">
		  <img id="vizIcon" width="68%" src="${urls.base}/themes/scholars/images/person_sa.png"/>
		</a>
		<p>Research Interests</p>
	</div>
	<div id="grants_icon_holder" style="display:none">
  		<a href="#" id="grants_trigger"><img id="vizIcon" width="40%" src="${urls.base}/themes/scholars/images/dept_grants.png"/></a>
		<p>Grants and Contracts</p>
	</div>
  <#elseif isCollegeOrSchool && !isJohnsonOrHotelSchool>
	<div id="grants_icon_holder" style="display:none">
  		<a href="#" id="grants_trigger" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Department-School', 'Research-Grants']);">
  			<img id="vizIcon" width="40%" src="${urls.base}/themes/scholars/images/dept_grants.png"/>
  		</a>
		<p>Grants and Contracts</p>
	</div>
	<div id="interd_collab_icon_holder" style="display:none">
		<a id="interd_collab_trigger" class="jqModal" href="#" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'College', 'Interdepartmental-Co-authorships']);">
			<img id="vizIcon" width="54%" src="${urls.base}/themes/scholars/images/interd_collab.png"/>
		</a>
		<p>Interdepartmental<br/>Co-authorships</p>
	</div>
	<div id="cross_unit_collab_icon_holder" style="display:none">
		<a id="cross_unit_collab_trigger" class="jqModal" href="#" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'College', 'Cross-unit-Co-authorships']);">
			<img id="vizIcon" width="54%" src="${urls.base}/themes/scholars/images/cross_unit_collab.png"/>
		</a>
		<p>Cross-unit<br/>Co-authorships</p>
	</div>
  <#else>
	<#-- Do not display anything if the individual is neither an academic department nor a college. -->
    <div id="visualization-column" class="col-sm-3 col-md-3 col-lg-3 scholars-container">
    </div>
  </#if>
  <#if isAcademicDept || isCollegeOrSchool >
  	</div>
  </#if>
</#assign>

<#assign facultyDeptListColumn >
  <#if (!isCollegeOrSchool && !isInstitute) && (facultyList?has_content || adminsGrant?has_content)>
	<div id="foafOrgTabs" class="col-md-8 scholars-container <#if !showVisualizations>scholars-container-full</#if>">
	  <#if facultyList?has_content || adminsGrant?has_content >
		<div id="scholars-tabs-container">
		  <ul id="scholars-tabs">
		    <#if facultyList?has_content ><li><a href="#tabs-1" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Department-School', 'People']);">People</a></li> </#if>
		    <#if showGrantsTab ><li><a href="#tabs-2" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Department-School', 'Grants']);">Grants</a></li></#if>
		  </ul>
		  <#if facultyList?has_content>
			  <div id="tabs-1" class="tab-content" data="${publicationsProp!}-dude">
					<article class="property" role="article">
			    		<ul id="individual-faculty" class="property-list" role="list" >
			    			${facultyList?replace(" position","")!}
						</ul>
					</article>	
			  </div>
		  </#if>
		  <#if showGrantsTab >
			  <div id="tabs-2"  class="tab-content">
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
  <#elseif isCollegeOrSchool && (subOrgs?has_content || (facultyList?has_content) && showPeopleTab)>
	<div id="foafOrgTabs" class="col-md-8 scholars-container <#if !showVisualizations>scholars-container-full</#if>">
		<div id="scholars-tabs-container">
		  <ul id="scholars-tabs">
		    <#if subOrgs?has_content ><li><a href="#tabs-1">Academic Units</a></li></#if>
		    <#if showPeopleTab ><li><a href="#tabs-2">People</a></li> </#if>
		  </ul>
			  <#if subOrgs?has_content >
				  <div id="tabs-1"  class="tab-content" data="${publicationsProp!}-dude">
					<article class="property" role="article">
				    <ul id="individual-faculty" class="property-list" role="list">
				    	${subOrgs!}
					</ul>
					</article>	
				  </div>
			  </#if>
			  <#if showPeopleTab>
				  <div id="tabs-2" class="tab-content" data="${publicationsProp!}-dude">
					<article class="property" role="article">
				    	<ul id="individual-faculty" class="property-list" role="list" >
			    			${facultyList?replace(" position","")!}
						</ul>
					</article>	
				  </div>
			  </#if>
		</div>
	</div>
  <#elseif isInstitute && (showPeopleTab || showGrantsTab)>
	<div id="foafOrgTabs" class="col-md-8 scholars-container <#if !showVisualizations>scholars-container-full</#if>">
		<div id="scholars-tabs-container">
		  <ul id="scholars-tabs">
		    <#if showPeopleTab ><li><a href="#tabs-1" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Department-School', 'People']);">People</a></li> </#if>
		    <#if showGrantsTab ><li><a href="#tabs-2" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Department-School', 'Grants']);">Grants</a></li></#if>
		  </ul>
			  <#if showPeopleTab >
				  <div id="tabs-1" class="tab-content" data="${publicationsProp!}-dude">
					<article class="property" role="article">
					  <#if affiliationList?has_content && (affiliationList?string?replace(" ","")?replace("\n","")?length > 0 ) >
				    	<ul id="individual-faculty" class="property-list" role="list" >
			    			${affiliationList!}
						</ul>
					  </#if>
					  <#if facultyList?has_content && (facultyList?string?replace(" ","")?replace("\n","")?length > 0 ) >
				    	<ul id="individual-faculty" class="property-list" role="list" >
			    			${facultyList?replace(" position","")!}
						</ul>
					  </#if>
					</article>	
				  </div>
			  </#if>
   			  <#if showGrantsTab >
   				  <div id="tabs-2"  class="tab-content">
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
	</div>
  <#else>
	<#-- Don't display anything if the individual is neither an academic department nor a college -->
  </#if>
</#assign>
<#-- Default individual profile page template -->
<#-- The row1 div contains the top portion of the profile page: name, photo, icon controls -->
<div id="row1" class="row scholars-row">
<div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="foafOrgMainColumn">
	<section id="individual-info" ${infoClass!} role="region">
	    <#include "individual-adminPanel.ftl">


	    <header>
	        <#if relatedSubject??>
	            <h2>${relatedSubject.relatingPredicateDomainPublic} for ${relatedSubject.name}</h2>
	            <p><a href="${relatedSubject.url}" title="${i18n().return_to(relatedSubject.name)}">&larr; ${i18n().return_to(relatedSubject.name)}</a></p>                
	        <#else>                
	            <h1 class="fn foaf-organization" itemprop="name">
	                <#-- Label -->
	                <@p.label individual editable labelCount localesCount languageCount/>
	                <#--  Most-specific types -->
	                <@p.mostSpecificTypes individual />
	            </h1>
	        </#if>
			<div id="foaf-organization-icons">
				<#include "individual-iconControls.ftl" />
			</div>
			<h2 id="page-heading-break">  </h2>
	    </header>
		<div class="clear-both"></div>
		<div id="academic-officer-list">
			${academicOfficerList!"&nbsp;"}
		</div>
	 </section> <!-- individual-info -->
			<div class="clear-both"></div>
	</div> <!-- foafPersonMainColumn -->
</div> <!-- row1 -->

<#assign nameForOtherGroup = "${i18n().other}"> 

<#-- The row2 div contains the visualization section and the faculty or department list, separated by a "spacer" column -->
<div id="row2" class="row scholars-row foaf-organization-row2" style="display:none;">
	<#if showVisualizations>${visualizationColumn}</#if>
	<div id="foafOrgSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
	${facultyDeptListColumn}
</div> <!-- row2 div subOrgs -->
<#if !facultyList?has_content || !adminsGrant?has_content || !subOrgs?has_content>
	<div id="foaf-organization-blank-row"></div>
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
	  $( "#scholars-tabs-container" ).tabs();
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

<#-- 
=======================================================================
Visualizations
======================================================================= 
-->

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/kwcloud.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/grants/bubble_chart.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.qtip.min.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/collaborations/collab.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis-2.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/FileSaver.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/stupidtable.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/transform-data.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/grants_tooltip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/bubble_chart_script.js"></script>'
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/collaborations/collaborations.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/word-cloud.js"></script>')}

<#-- 
=======================================================================
Word-cloud vis
======================================================================= 
-->

<div id="word_cloud_vis" class="vis_modal" style="display:none; ">
  <div class="vis_toolbar">
    <span class="heading">Research Keywords</span>
    <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
    <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right" style="display: none">Show visualization</a>
    <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
  </div>
  
  <div id="info_icon_text" style="display:none">
    <p>
      This visualization displays the research keywords for an entire academic unit, 
      and is an aggregation of the keywords found in all the articles authored by all 
      faculty and researchers of an academic unit. The size of the keyword indicates 
      the frequency with which the keyword appears in the author's publications, 
      indicating which subjects the author published on most (or least) frequently. 
    </p>
    <p>
      To interact with the visualization, click on any keyword to see the list of 
      authors that have this keyword associated with one of more of their articles. 
      One can click on the author's name in the list to go to the author's page, 
      which contains the full list of author's publications in Scholars.
    </p>
    <hr> 
    <p>
      Note: This information is based solely on publications that have been loaded into the system.
    </p> 
  </div>
  
  <div data-view-id="vis" class="vis-container">
    <div class="vis-exports-container" >
      <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="svg" style="margin-right: 7px;" class="vis-view-toggle pull-right">Export as SVG</a>
	</div>
    <font size="2">
      <span><i>Click on a keyword to view the list of the relevant faculty.</i></span>
      <#--	
      <label class="boxLabel"><input id="keyword" type="checkbox" class="cbox" checked>Article Keywords<span id="kw">(0)</span></label>
      <label class="boxLabel"><input id="mined" type="checkbox" class="cbox" checked>Inferred Keywords<span id="minedt">(0)</span></label>
      <label class="boxLabel"><input id="mesh" type="checkbox" class="cbox" checked>Mesh Terms<span id="mt">(0)</span></label> 
      -->
    </font>
  </div>

  <div data-view-id="table" class="vis-table-container">
    <div class="vis-exports-container">
      <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
    </div>
    <h1>Table by Keyword</h1>
    <table class="scholars-vis-table">
      <thead>
        <tr>
          <th data-sort="string-ins">Keyword</th>
          <th data-sort="string-ins">Faculty Member</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Template row</td>
          <td>Template row</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<#if isCollegeOrSchool >
<#-- 
=======================================================================
Inter-departmental Collaboration Vis
======================================================================= 
-->

<div id="interd_collab_vis" class="vis_modal dept_collab_vis" style="display:none; ">
  <div class="vis_toolbar">
    <span class="heading">Interdepartmental Co-authorships (Faculty only)</span>
    <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
    <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right" style="display: none">Show visualization</a>
    <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
  </div>
  
  <div id="info_icon_text" style="display:none">
    <p>
      The interdepartmental co-authorships are identified based on the affiliation 
      data extracted from the citation of a publication. Currently, we only present 
      co-authorships between researchers with faculty appointments. 
      This visualization has a zoom-in/zoom-out functionality. The visualization 
      consists of three layers: a department-level layer (inner most), person-level 
      layer 1 (i.e., author in context), and the person-level layer 2 (i.e., the co-authors). 
    </p>
    <p>
      To view the co-authorships, begin by selecting a department of interest. 
      In this view, you can observe who has co-authored with whom and how often they 
      co-authored. To view the co-authored publications, begin by selecting a 
      faculty member of interest. In this view, clicking on a co-author (in the 
      outer circle) displays the list of co-authored articles in the tooltip. 
      Click in the center circle to zoom out to select any other faculty/department of interest.
    </p>
    <hr> 
    <p>
      Note: This information is based solely on publications that have been loaded into the system.
    </p> 
  </div>

  <div data-view-id="vis" class="vis-container">
    <div class="vis-exports-container" >
      <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="svg" style="margin-right: 7px;" class="vis-view-toggle pull-right">Export as SVG</a>
	</div>
    <font size="2">
      <span><i>
        Click on any arc to zoom in and on the center circle to zoom out.
        Once zoomed in on a faculty member, click on the outer arc to view a list of co-authored publications.
      </i></span>
    </font>
  </div>

  <div data-view-id="table" class="vis-table-container">
    <div class="vis-exports-container">
      <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
    </div>
    <table class="scholars-vis-table">
      <thead>
        <tr>
          <th data-sort="string-ins">Author</th>
          <th data-sort="string-ins">Author Organization</th>
          <th data-sort="string-ins">Co-Author</th>
          <th data-sort="string-ins">Co-Author Organization</th>
          <th data-sort="string-ins">Publication</th>
          <th data-sort="string-ins">Publication Date</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<#-- 
=======================================================================
Cross-unit Collaboration Vis
======================================================================= 
-->

<div id="cross_unit_collab_vis" class="vis_modal dept_collab_vis" style="display:none; ">
  <div class="vis_toolbar">
    <span class="heading">Cross-unit Co-authorships (Faculty only)</span>
    <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
    <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right" style="display: none">Show visualization</a>
    <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
  </div>
  
  <div id="info_icon_text" style="display:none">
    <p>
      The cross-unit co-authorships are identified based on the affiliation data 
      extracted from the citation of a publication. Currently, we only present 
      co-authorships between researchers with faculty appointments. This visualization 
      has a zoom-in/zoom-out functionality. The visualization consists of three layers: 
      unit-level layer (inner most), person-level layer 1 (i.e., author in context) and 
      the person-level layer 2 (i.e., the co-authors). 
    </p>
    <p>
      To view the co-authorships, begin by selecting  an academic unit of interest. 
      In this view, you can observe who has co-authored with whom and how often they 
      co-authored. To view the co-authored publications, begin by selecting a faculty 
      member of interest. In this view, clicking on a co-author (in the outer circle) 
      displays the list of co-authored articles in the tooltip. Click in the center 
      circle to zoom out to select any other faculty/academic unit of interest.
    </p>
    <hr> 
    <p>
      Note: This information is based solely on publications that have been loaded into the system.
    </p>
  </div>

  <div data-view-id="vis" class="vis-container">
    <div class="vis-exports-container" >
      <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="svg" style="margin-right: 7px;" class="vis-view-toggle pull-right">Export as SVG</a>
	</div>
    <font size="2">
      <span><i>
        Click on any arc to zoom in and on the center circle to zoom out.
	    Once zoomed in on a faculty member, click on the outer arc to view a list of co-authored publications.
      </i></span>
    </font>
  </div>

  <div data-view-id="table" class="vis-table-container">
    <div class="vis-exports-container">
      <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
    </div>
    <table class="scholars-vis-table">
      <thead>
        <tr>
          <th data-sort="string-ins">Author</th>
          <th data-sort="string-ins">Author Organization</th>
          <th data-sort="string-ins">Co-Author</th>
          <th data-sort="string-ins">Co-Author Organization</th>
          <th data-sort="string-ins">Publication</th>
          <th data-sort="string-ins">Publication Date</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
          <td>Template row</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<script>
var isJohnsonOrHotelSchool = ${isJohnsonOrHotelSchool?string};
$().ready(function() {
    if ($('#word_cloud_icon_holder')) {
        var wc = new ScholarsVis2.DepartmentWordCloud({
            target : '#word_cloud_vis',
            modal : true,
            department : "${individual.uri?url}",
            animation : true
        });
        wc.examineData(function(data) {
            if (data.length > 0) {
                $('#word_cloud_icon_holder').show();
                $('#word_cloud_trigger').click(showVis);
                $('#word_cloud_vis [data-view-selector]').click(showVisView);
                
                function showVis(e) {
                    $('#word_cloud_vis [data-view-selector]').show();
                    $('#word_cloud_vis [data-view-selector="vis"]').hide();
                    wc.show(e);
                }
                
                function showVisView(e) {
                    var viewId = $(e.target).data('view-selector');
                    $('#word_cloud_vis [data-view-selector]').show();
                    $('#word_cloud_vis [data-view-selector=' + viewId + ']').hide();
                    wc.showView(e);
                }
            }
        });
    }
    
    
    if (!isJohnsonOrHotelSchool) {
        $('#visualization-column').hide();
        
        var cucs = new ScholarsVis2.CrossUnitCollaborationSunburst({
            department : '${individual.uri}',
            target : '#cross_unit_collab_vis',
            modal : true
        });
        cucs.examineData(function(data) {
            if (data && data.children && data.children.length > 0) {
                $('#visualization-column').show();
                $('#cross_unit_collab_icon_holder').show();
                $('#cross_unit_collab_trigger').click(showVis);
                $('#cross_unit_collab_vis [data-view-selector]').click(showVisView);
                
                function showVis(e) {
                    $('#cross_unit_collab_vis [data-view-selector]').show();
                    $('#cross_unit_collab_vis [data-view-selector="vis"]').hide();
                    cucs.show(e);
                }
                
                function showVisView(e) {
                    var viewId = $(e.target).data('view-selector');
                    $('#cross_unit_collab_vis [data-view-selector]').show();
                    $('#cross_unit_collab_vis [data-view-selector=' + viewId + ']').hide();
                    cucs.showView(e);
                }
            }
        });
        
        var idcs = new ScholarsVis2.InterDepartmentCollaborationSunburst({
            department : '${individual.uri}',
            target : '#interd_collab_vis',
            modal : true
        });
        idcs.examineData(function(data) {
            if (data && data.children && data.children.length > 0) {
                $('#visualization-column').show();
                $('#interd_collab_icon_holder').show();
                $('#interd_collab_trigger').click(idcs.show);
                $('#interd_collab_trigger').click(showVis);
                $('#interd_collab_vis [data-view-selector]').click(showVisView);
                
                function showVis(e) {
                    $('#interd_collab_vis [data-view-selector]').show();
                    $('#interd_collab_vis [data-view-selector="vis"]').hide();
                    idcs.show(e);
                }
                
                function showVisView(e) {
                    var viewId = $(e.target).data('view-selector');
                    $('#interd_collab_vis [data-view-selector]').show();
                    $('#interd_collab_vis [data-view-selector=' + viewId + ']').hide();
                    idcs.showView(e);
                }
            }
        });
    }
});
</script>
<#-- 
=======================================================================
End visualizations
======================================================================= 
-->
</#if>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />',
					'<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-3.0.3.min.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}

<script type="text/javascript">
    i18n_confirmDelete = "${i18n().confirm_delete}"
</script>

<div id="modal_grants_vis" class="vis_modal dept_grants_vis" style="display:none">
  <div id="info_icon_text" style="display:none"> 
    <p>
      This visualization represents all the grants where a faculty member or a researcher of this department is either a Principal or Co-Principal Investigator. Grants data is represented as a cluster of bubbles where each bubble represents a grant and the size of the bubble indicates the relative award amount. The color scheme reveals the dollar amount range of the grant. This provides a quick visual view of the active research grants for the entire department. Clicking on a grant bubble will display the full description of the grant including title, list of investigators and other information.
    </p>
    <hr> 
    <p>
      Note: This information is based solely on grants that have been loaded into the 
      system through OSP (Office of Sponsored Program) feed.
    </p> 
  </div>
  <div>
    <font size="2">
      <span><i>
        Hover over a grant bubble to view the title of the grant, or click on a bubble to view the details of a funded grant.
      </i></span>
    </font>
  </div>
  
  <div id="grantsMainDiv"></div>
  <div id="grantsLegendDiv" class="grantsLegendDivXtra"></div>
</div>


<script>

  $().ready(function() {
    if ($('#grants_icon_holder')) {
      var g = new ScholarsVis.DepartmentGrants({
        target : '#modal_grants_vis',
        mainDiv : '#grantsMainDiv',
        legendDiv : '#grantsLegendDiv',
        modal : true,
        department : "${individual.uri}"
      });
      g.examineData(function(data) {
        if (data && data.length > 0) {
          $('#grants_icon_holder').show();
          $('#grants_trigger').click(g.show);
          $('#grants_exporter').click(g.showVisData);
        }
      });
      new ScholarsVis.Toolbar("#modal_grants_vis", "Browse Research Grants");
    }

	// because getting the data for the visualizations takes some time,
	// delay the display of the second row of the profile page 
	setTimeout(showRowTwo, 400);
	
	function showRowTwo() {
		$('.foaf-organization-row2').show();
	
		if ( $('#visualization-column').is(":hidden") ) {
			$('#foafOrgTabs').addClass('scholars-container-full');
		}
	}

  });

</script>
