<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->

<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

    

<#import "lib-microformats.ftl" as mf>
<#import "lib-datetime.ftl" as dt>
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
<#-- pull properties -->
<#assign abstractProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/abstract")!>
<#assign princInvstsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#relates","http://vivoweb.org/ontology/core#PrincipalInvestigatorRole")!>
<#assign coprincInvstsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#relates","http://vivoweb.org/ontology/core#CoPrincipalInvestigatorRole")!>
<#assign awardedByProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#assignedBy","http://xmlns.com/foaf/0.1/Organization")!>
<#assign adminByProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#relates","http://vivoweb.org/ontology/core#AdministratorRole")!>
<#assign yearsActiveProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#dateTimeInterval")!>
<#assign amountProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#totalAwardAmount")!>
<#assign keywordsProp = propertyGroups.pullProperty("http://scholars.cornell.edu/ontology/vivoc.owl#inferredKeyword")!>

<#if abstractProp?has_content && abstractProp.statements?has_content>
	<#assign abstractStmt = abstractProp.statements?first />
	<#assign abstract >
		<div id="abstract-hdr" class="profile-label">Abstract</div>
		<div class="abstract-text" style="max-height:650px;overflow:auto">
			${abstractStmt.value!}
		</div>
	</#assign>
</#if>
<#if princInvstsProp?has_content && princInvstsProp.statements?has_content>
	<#assign pis = [] />
	<#assign piList>
		<div class="row profile-row" role="row">
		  <div class="col-sm-3 no-padding align-text-right" >
			<span class="profile-label">Principal Investigator<#if (princInvstsProp.statements?size > 1)>s</#if></span>
		  </div>
		  <div class="col-sm-9 ">
			<div class="scholars-article-metadata">
			<#list princInvstsProp.statements as statement>
				<span class="hzntl-author-list">
		        	<a href="${profileUrl(statement.uri("indivInRole"))}"">${statement.indivLabel}</a>
		        	<#if statement_has_next>,</span><#else></span></#if>
		        	<#assign pis = pis + [statement.indivLabel?trim] />
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if coprincInvstsProp?has_content && coprincInvstsProp.statements?has_content>
	<#assign copiList>
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-3 no-padding align-text-right" >
			<span class="profile-label">Co-principal<#if (coprincInvstsProp.statements?size > 1)>s</#if></span>
		  </div>
		  <div class="col-sm-9 ">
			<div class="scholars-article-metadata">
			<#list coprincInvstsProp.statements as statement>
				<span class="hzntl-author-list">
		        	<a href="${profileUrl(statement.uri("indivInRole"))}"">${statement.indivLabel}</a><#if statement_has_next>,</span><#else></span></#if>
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if awardedByProp?has_content && awardedByProp.statements?has_content>
	<#assign awardedByList>
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-3 no-padding align-text-right" >
			<span class="profile-label">Funding Agency</span>
		  </div>
		  <div class="col-sm-9 ">
			<div class="scholars-article-metadata">
			<#list awardedByProp.statements as statement>
				<span class="hzntl-author-list">
		        	<a href="${profileUrl(statement.uri("object"))}"">${statement.label?capitalize?replace("Nsf","NSF")?replace("Nih","NIH")?replace("Dhhs","DHHS")?replace("usda","USDA")?replace("Usda","USDA")?replace("A&m","A&M")?replace("Doe","DOE")?replace("Dod","DOD")?replace("Rsch","RSCH")?replace("Res","RES")?replace("Ltd","LTD")?replace("Fdn","FDN")?replace("Doi","DOI")?replace("Gsa","GSA")?replace("Doc","DOC")?replace(" Us"," US")}</a>
		        	<#if statement_has_next>,</span><#else></span></#if>
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if adminByProp?has_content && adminByProp.statements?has_content>
	<#assign adminByList>
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-3 no-padding align-text-right" >
			<span class="profile-label">Administered By</span>
		  </div>
		  <div class="col-sm-9 ">
			<div class="scholars-article-metadata">
			<#list adminByProp.statements as statement>
				<span class="hzntl-author-list">
		        	<a href="${profileUrl(statement.uri("organization"))}"">${statement.organizationLabel!}</a>
		        	<#if statement_has_next>,</span><#else></span></#if>
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if yearsActiveProp?has_content && yearsActiveProp.statements?has_content>
	<#assign yearsActiveStmt = yearsActiveProp.statements?first!""/>
	<#assign yearsActiveDisplay>
		<div class="row profile-row" role="row">
		  <div class="col-sm-5  no-padding align-text-right">
			<span class="profile-label">Years Active</span>
		  </div>
		  <#setting date_format="yyyy"> 
		  <#setting locale="en_US">
		  <#assign sYear = yearsActiveStmt.dateTimeStart[0..3]?date('yyyy') />
		  <#assign eYear =yearsActiveStmt.dateTimeEnd[0..3]?date('yyyy') />
		  <div class="col-sm-7 ">
			<div class="scholars-article-metadata">
				${sYear!} - ${eYear!}
			</div>
	  	  </div>
		</div>
	</#assign>
</#if>  
<#if amountProp?has_content && amountProp.statements?has_content>
	<#assign amountStmt = amountProp.statements?first!""/>
	<#assign amount >
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-5  no-padding align-text-right">
			<span class="profile-label">Amount</span>
		  </div>
		  <div class="col-sm-7 ">
			<div class="scholars-article-metadata">
				$${amountStmt.value?string?replace(".0","")?number}
			</div>
	  	  </div>
		</div>
	</#assign>
</#if>  
<#if keywordsProp?has_content && keywordsProp.statements?has_content>
	<#assign keywordsList>
		<div class="col-sm-3 no-padding align-text-right">
  			<span class="profile-label">Keywords</span>
		</div>
		<div class="col-sm-9 no-padding" style="max-height:400px;overflow:auto">
  			<div class="mesh-term-list">
  				<ul>
  					<#list keywordsProp.statements as statement>
  						<li class="list-item">
  							${statement.value!}.
  						</li>
  					</#list>
  				</ul>
  			</div>
		</div>
	</#assign>
	<#assign keywordsListInline>
		<div class="col-sm-1 align-text-right">
  			<span class="profile-label">Keywords</span>
		</div>
		<div class="col-sm-10" >
  			<div class="mesh-term-list" style="max-height:400px;overflow:auto">
  				<ul>
  					<#list keywordsProp.statements as statement>
  							${statement.value!}<#if statement_has_next> | </#if>
  					</#list>
  				</ul>
  			</div>
		</div>
	</#assign>
</#if>
<#-- The row1 div contains the top portion of the profile page: tile, icon controls, authors, key metadata -->
<div id="row1" class="row f1f2f3-bkg">
<div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="biboDocumentMainColumn">

<section id="individual-info" ${infoClass!} role="region">
    <#include "individual-adminPanel.ftl">

    <#if individualProductExtensionPreHeader??>
        ${individualProductExtensionPreHeader}
    </#if>
	
    <header>
			<#include "individual-altmetric.ftl">
            <h1 class="fn grant-profile-title" itemprop="name">
                <#-- Label -->
                <@p.label individual editable labelCount localesCount languageCount/>
                <#--  Most-specific types -->
                <@p.mostSpecificTypes individual />
            </h1>
		<div class="bibo-doc-controls">
			<#include "document-iconControls.ftl" />
		</div>

		<h2 id="bibo-heading-break">  </h2>
    </header>
	<div class="row profile-row fff-bkg header-metadata" role="row">
		<div class="col-sm-9 col-md-9 col-lg-9 no-padding">
				${piList!?replace(" ,",",")!}
				${copiList!?replace(" ,",",")}
				${adminByList!}
				${awardedByList!}
		</div>

		<div class="col-sm-3 col-md-3 col-lg-3 no-padding">
				${yearsActiveDisplay!}
				${amount!}
		</div>
	</div>


        </section> <!-- individual-info -->
		<div class="clear-both"></div>

	</div> <!-- biboDocumentMainColumn -->
</div> <!-- row1 -->
<#if keywordsList?has_content && abstract?has_content>
	<div id="bibo-row-two" class="row f1f2f3-bkg">
	  <div class="col-sm-5 col-md-5 col-lg-5 f1f2f3-bkg">
		  <div class="row f1f2f3-bkg row-no-margins">
				<div id="keywords" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
					<div class="row profile-row profile-row-margins">
						${keywordsList!}
					</div>
				</div>
			</div>
	  </div>
	  <div class="col-sm-7 col-md-7 col-lg-7 no-padding">
		<div class="row f1f2f3-bkg row-no-margins">
			<div id="abstract" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				${abstract!}
			</div>
		</div>
	  </div>
</#if>
<#if keywordsList?has_content && !abstract?has_content>
	<div id="bibo-row-two" class="row f1f2f3-bkg">
	  <div class="col-sm-12 col-md-12 col-lg-12 f1f2f3-bkg">
		  <div class="row f1f2f3-bkg row-no-margins">
				<div id="keywords" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
					<div class="row profile-row profile-row-margins">
						${keywordsListInline!}
					</div>
				</div>
			</div>
	  </div>
</#if>
<#if !keywordsList?has_content && abstract?has_content>
	<div id="bibo-row-two" class="row f1f2f3-bkg">
	  <div class="col-sm-12 col-md-12 col-lg-12 no-padding">
		<div class="row f1f2f3-bkg row-no-margins">
			<div id="abstract" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				${abstract!}
			</div>
		</div>
	  </div>
</#if>
	</div> <!-- row2 div -->

<#assign rdfUrl = individual.rdfUrl>
<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>

<div id="profile-bottom" class="row f1f2f3-bkg"></div>

<script>
    var individualLocalName = "${individual.localName}";
</script>
<script>
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


<#assign pubTitle = "not found" />

<#if pubVenue?has_content >
	<#assign pubTitle = pubVenue.label />
	<#elseif freeTextTitleStmt?has_content >
	<#assign pubTitle = freeTextTitleStmt.value />
</#if>

<script type="application/ld+json">
{
  "@context": "http://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "${individual.name?replace("\"","")!} (",
  "name": "${individual.name?replace("\"","")!}",
  "datePublished": "${pubDate!}",
  "pageStart": "${startPage!}",
  "pageEnd": "${endPage!}",
   "publisher": {
    "@type": "Periodical",
    "name": "${pubTitle!}"
  }
}
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />',
				  '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.qtip.min.css" />',
				  '<link rel="stylesheet" href="${urls.base}/css/individual/individual.css?vers=1.5.1" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-3.0.3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}
