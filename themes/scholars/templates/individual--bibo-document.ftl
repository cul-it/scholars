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
<#assign authorsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#relatedBy","http://vivoweb.org/ontology/core#Authorship")!>
<#assign editorsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#relatedBy","http://vivoweb.org/ontology/core#Editorship")!>
<#assign pubDateProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#dateTimeValue","http://vivoweb.org/ontology/core#DateTimeValue")!>
<#if pubDateProp?has_content && pubDateProp.statements?has_content>
	<#assign pubDateStmt = pubDateProp.statements?first/>
	<#assign pubDate>${dt.formatXsdDateTimeLong(pubDateStmt.dateTime, pubDateStmt.precision!)}</#assign>
</#if>
<#assign pubLocaleProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#placeOfPublication")!>
<#assign pubVenueProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#hasPublicationVenue")!>
<#assign keywordsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#freetextKeyword")!>
<#assign meshTermsProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#hasSubjectArea")!>
<#assign doiProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/doi")!>
<#assign startProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pageStart")!>
<#assign endProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pageEnd")!>
<#assign volumeProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/volume")!>
<#assign issueProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/issue")!>
<#assign gccProp = propertyGroups.pullProperty("http://purl.org/spar/c4o/hasGlobalCitationFrequency")!>
<#assign pmidProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pmid")!>
<#assign freeTextTitleProp = propertyGroups.pullProperty("http://scholars.cornell.edu/ontology/vivoc.owl#freetextJournalTitle")!>
<#if libraryCatalogPage?has_content>
	<#assign lcp = libraryCatalogPage[0].lcp />
</#if>
<#if abstractProp?has_content && abstractProp.statements?has_content>
	<#assign abstractStmt = abstractProp.statements?first />
	<#assign abstract >
		<div id="abstract-hdr" class="profile-label">Abstract</div>
		<div class="abstract-text">
			${abstractStmt.value!}
		</div>
	</#assign>
</#if>
<#if authorsProp?has_content && authorsProp.statements?has_content>
	<#assign authors = [] />
	<#assign authorList>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1 no-padding align-text-right" >
			<span class="profile-label">Authors</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
			<#list authorsProp.statements as statement>
				<span class="hzntl-author-list">
		    	<#if statement.subclass?? && statement.subclass?contains("vcard")>
					<#if statement.authorName?replace(" ","")?length == statement.authorName?replace(" ","")?last_index_of(",") + 1 >
		        		${statement.authorName?replace(",","")}
		        		<#assign authors = authors + [statement.authorName?trim] />
					<#else>
						${statement.authorName}<#if statement_has_next>,</span>
     					<#else></span></#if>
     					<#assign authors = authors + [statement.authorName?trim] />
					</#if>
		    	<#else>
		        	<a href="${profileUrl(statement.uri("author"))}" title="${i18n().author_name}">${statement.authorName}</a>
		        	<#if statement_has_next>,</span><#else></span></#if>
		        	<#assign authors = authors + [statement.authorName?trim] />
		    	</#if>
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if lcpProp?has_content && lcpProp.statements?has_content>
	<#assign lcp = volumeProp.statements[0].value />
</#if>
<#if pubVenueProp?has_content && pubVenueProp.statements?has_content>
	<#assign pubVenue = pubVenueProp.statements?first/>
	<#assign journalTitle>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right">
			<span class="profile-label">Journal</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				<em><a href="${profileUrl(pubVenue.object)}" title="${pubVenue.label!}" onclick="javascript:_paq.push(['trackEvent', 'Link', 'Publication', 'Journal']);">${pubVenue.label!}</a></em>
				<#if lcp??><a href="${lcp}" target="_blank"><i class="fa fa-external-link-square external-link" aria-hidden="true"></i></a></#if>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if volumeProp?has_content && volumeProp.statements?has_content>
	<#assign volumeStmt = volumeProp.statements?first />
	<#assign volume = true />
<#else>
	<#assign volume = false />
</#if>
<#if issueProp?has_content && issueProp.statements?has_content>
	<#assign issueStmt = issueProp.statements?first!""/>
	<#assign issue = true />
<#else>
	<#assign issue = false />
</#if>
<#if volume && issue >
	<#assign volumeIssue>
		<div class="row profile-row" role="row">
		  <div class="col-sm-9 no-padding align-text-right">
			<span class="profile-label">Volume(Issue)</span>
		  </div>
		  <div class="col-sm-3">
			<div class="scholars-article-metadata">
				${volumeStmt.value!}(${issueStmt.value!})
			</div>
		  </div>
		</div>
	</#assign>
<#elseif volume && !issue >
	<#assign volumeIssue>
		<div class="row profile-row" role="row">
		  <div class="col-sm-9 no-padding align-text-right">
			<span class="profile-label">Volume</span>
		  </div>
		  <div class="col-sm-3">
			<div class="scholars-article-metadata">
				${volumeStmt.value!}
			</div>
		  </div>
		</div>
	</#assign>
<#elseif !volume && issue >
	<#assign volumeIssue>
		<div class="row profile-row" role="row">
		  <div class="col-sm-9 no-padding align-text-right">
			<span class="profile-label">Issue</span>
		  </div>
		  <div class="col-sm-3">
			<div class="scholars-article-metadata">
				${issueStmt.value!}
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if freeTextTitleProp?has_content && freeTextTitleProp.statements?has_content>
	<#assign freeTextTitleStmt = freeTextTitleProp.statements?first!""/>
	<#assign freeTextTitle>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right">
			<span class="profile-label">Journal</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				<em>${freeTextTitleStmt.value!}</em>
			</div>
	  	  </div>
		</div>
	</#assign>
</#if>  
<#if startProp?has_content && startProp.statements?has_content>
	<#assign startPageStmt = startProp.statements?first!""/>
	<#assign startPage = startPageStmt.value! />
</#if>  
<#if endProp?has_content && endProp.statements?has_content>
	<#assign endPageStmt = endProp.statements?first!""/>
	<#assign endPage = endPageStmt.value!/>
</#if>
<#if startPage?has_content && endPage?has_content >
	<#assign pages>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right">
			<span class="profile-label">Pages</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				${startPage!} - ${endPage!}
			</div>
		  </div>
		</div>
	</#assign>
<#elseif startPage?has_content && !endPage?has_content >
	<#assign pages>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right">
			<span class="profile-label">Starts</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				${startPage!}
			</div>
		  </div>
		</div>
	</#assign>
<#elseif !startPage?has_content && endPage?has_content >
	<#assign pages>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right>
			<span class="profile-label">Ends</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				${endPage!}
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if pubDate?has_content>
	<#assign publishedInline >
		<div class="row profile-row" role="row">
		  <div class="col-sm-9 no-padding align-text-right">
			<span class="profile-label">Published</span>
		  </div>
		  <div class="col-sm-3">
			<div class="scholars-article-metadata">
				${pubDate!}
			</div>
		  </div>
		</div>
	</#assign>

</#if>
<#if gccProp?has_content && gccProp.statements?has_content >
	<#assign gcc>
		<div class="row profile-row" role="row">
		  <div class="col-sm-9 no-padding align-text-right">
			<span class="profile-label">Citations</span>
		  </div>
		  <div class="col-sm-3" >
			<div class="scholars-article-metadata">
				${gccProp.statements[0].count!}
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if doiProp?has_content && doiProp.statements?has_content>
	<#assign doiStmt = doiProp.statements?first!""/>
	<#assign doi = doiStmt.value! />
	<#assign doiInline>
		<div class="row profile-row" role="row">
		  <div class="col-sm-1  no-padding align-text-right">
			<span class="profile-label">DOI</span>
		  </div>
		  <div class="col-sm-10">
			<div class="scholars-article-metadata">
				<a href="http://dx.doi.org/${doi!}" title="link to DOI" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Link', 'Publication', 'DOI']);">${doi!}</a>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if pmidProp?has_content && pmidProp.statements?has_content>
	<#assign pmidStmt = pmidProp.statements?first!""/>
	<#assign pmid = pmidStmt.value! />
	<#assign pmidInline>
		<div class="row profile-row" role="row">
		  <div class="col-sm-9  no-padding align-text-right">
			<span class="profile-label">PMID</span>
		  </div>
		  <div class="col-sm-3">
			<div class="scholars-article-metadata">
				<a href="http://www.ncbi.nlm.nih.gov/pubmed/?term=${pmid!}" title="View in PubMed" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Link', 'Publication', 'PMID']);">${pmid!}</a>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if doi?has_content>
	<#assign fullTextLink = "http://dx.doi.org/${doi!}" />
<#elseif pmid?has_content>
	<#assign fullTextLink = "http://www.ncbi.nlm.nih.gov/pubmed/?term=${pmid!}" />
</#if>
<#if keywordsProp?has_content && keywordsProp.statements?has_content>
	<#assign keywordsList>
		<div class="col-sm-3 no-padding align-text-right">
  			<span class="profile-label">Keywords</span>
		</div>
		<div class="col-sm-9 no-padding">
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
  			<div class="mesh-term-list">
  				<ul>
  					<#list keywordsProp.statements as statement>
  							${statement.value!}<#if statement_has_next> | </#if>
  					</#list>
  				</ul>
  			</div>
		</div>
	</#assign>
</#if>
<#assign hasMeshTerm = false />
<#if meshTermsProp?has_content && meshTermsProp.statements?has_content>
	<#assign meshTermsList>
		<div class="col-sm-3 no-padding align-text-right ws-nowrap">
  			<span class="profile-label">MeSH Terms</span>
		</div>
		<div class="col-sm-9 no-padding">
  			<div class="mesh-term-list">
  				<ul>
					<#list meshTermsProp.statements as statement>
						<#if statement.concept?contains("mesh")>
							<#assign hasMeshTerm = true />
							<li class="list-item">
								<a href="${statement.concept!}" target="_blank">${statement.conceptLabel!}</a>.
							</li>
						</#if>
					</#list>
  				</ul>
  			</div>
		</div>
	</#assign>
	<#assign meshTermsListInline>
		<div class="col-sm-1 align-text-right ws-nowrap">
  			<span class="profile-label">MeSH Terms</span>
		</div>
		<div id="inlineMeshTerms" class="col-sm-10">
  			<div class="mesh-term-list">
  				<ul>
					<#list meshTermsProp.statements as statement>
						<#if statement.concept?contains("mesh")>
							<#assign hasMeshTerm = true />
		  					<li class="inline-meshterm"><a href="${statement.concept!}" target="_blank">${statement.conceptLabel!}</a><#if statement_has_next> | </#if></li>
						</#if>
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
            <h1 class="fn bibo-profile-title" itemprop="name">
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
		<div class="col-sm-9 col-md-9 col-lg-9">
 			${authorList?replace(" ,",",")!}
 			<#if journalTitle?has_content >
 				${journalTitle!}
 			<#else>
 				${freeTextTitle!}
 			</#if>
 			${pages!}
 			${doiInline!}
		</div>

		<div class="col-sm-2 col-md-2 col-lg-2">
				${gcc!}
				${volumeIssue!}
				${publishedInline!}
				${pmidInline!}
		</div>
	</div>


        </section> <!-- individual-info -->
		<div class="clear-both"></div>

	</div> <!-- biboDocumentMainColumn -->
</div> <!-- row1 -->
<#if abstract?has_content || keywordsList?has_content || hasMeshTerm >
	<div id="bibo-row-two" class="row f1f2f3-bkg">
	<#if abstract?has_content>
	  <div class="col-sm-5 col-md-5 col-lg-5 f1f2f3-bkg">
  	  <#if keywordsList?has_content>
	    <div class="row f1f2f3-bkg row-no-margins">
			<div id="keywords" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				<div class="row profile-row profile-row-margins" >
					${keywordsList!}
				</div>
				<div class="row profile-row profile-row-margins" >
				</div>
			</div>
		</div>
		</#if>
		<#if hasMeshTerm>
	    <div class="row f1f2f3-bkg row-no-margins">
			<div id="keywords" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				<div class="row profile-row profile-row-margins" >
					${meshTermsList!}
				</div>
				<div class="row profile-row profile-row-margins" >
				</div>
			</div>
		</div>
		</#if>
	  </div>
	  <#if keywordsList?has_content || hasMeshTerm > 
	  <div class="col-sm-7 col-md-7 col-lg-7 no-padding">
		<div class="row f1f2f3-bkg row-no-margins">
			<div id="abstract" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				${abstract!}
				<div class="row profile-row profile-row-margins" >
			</div>
		</div>
	  </div>
	  <#else>
	  <div class="col-sm-12 col-md-12 col-lg-12 no-padding">
		<div class="row f1f2f3-bkg row-no-margins">
			<div id="abstract" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				${abstract!}
				<div class="row profile-row profile-row-margins" >
			</div>
		</div>
	  </div>
	  </#if>
	<#else>
		<#if keywordsList?has_content && hasMeshTerm>
		<div id="keywords" class="col-sm-5 col-md-5 col-lg-5 scholars-container" >
			<div class="row profile-row profile-row-margins" >
				${keywordsList!}
			</div>
			<div class="row profile-row profile-row-margins" >
			</div>
		</div>
		<div id="meshTerms" class="col-sm-5 col-md-5 col-lg-5 scholars-container col-sm-offset-2 col-md-offset-2 col-lg-offset-2">
			<div class="row profile-row profile-row-margins" >
				${meshTermsList!}
			</div>
			<div class="row profile-row profile-row-margins" >
			</div>
		</div>
		</#if>
		<#if keywordsList?has_content && !hasMeshTerm>
		<div id="foafPersonViz" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
			<div class="row profile-row profile-row-margins" >
				<div class="col-sm-12 col-md-12 col-lg-12">
							${keywordsListInline!}
				</div>
			</div>
		</div>
		</#if>
		<#if !keywordsList?has_content && hasMeshTerm>
		<div id="foafPersonViz" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
			<div class="row profile-row profile-row-margins" >
				<div class="col-sm-12 col-md-12 col-lg-12">
							${meshTermsListInline!}
				</div>
			</div>
		</div>
		</#if>
	</#if>
	</div> <!-- row2 div -->
</#if>
<#assign nameForOtherGroup = "${i18n().other}"> 

<!-- Property group menu or tabs -->
<#-- 
    With release 1.6 there are now two types of property group displays: the original property group
     menu and the horizontal tab display, which is the default. If you prefer to use the property
     group menu, simply substitute the include statement below with the one that appears after this
     comment section.
     
     <#include "individual-property-group-menus.ftl">
-->

<#-- include "individual-property-group-tabs.ftl" -->


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
  "headline": "${individual.name?replace("\"","")!} (${authors?first})",
  "name": "${individual.name?replace("\"","")!}",
  "datePublished": "${pubDate!}",
  "pageStart": "${startPage!}",
  "pageEnd": "${endPage!}",
  "author": [
		<#list authors as author>
			{
				"@type": "Person",
				"name": "${author}"
			}
			<#if author_has_next>, </#if></#list>
		],
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
