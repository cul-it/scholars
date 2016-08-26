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
<#assign doiProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/doi")!>
<#assign startProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pageStart")!>
<#assign endProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pageEnd")!>
<#assign volumeProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/volume")!>
<#assign issueProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/issue")!>
<#assign gccProp = propertyGroups.pullProperty("http://purl.org/spar/c4o/hasGlobalCitationFrequency")!>
<#assign pmidProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/pmid")!>
<#if libraryCatalogPage?has_content>
	<#assign lcp = libraryCatalogPage[0].lcp />
</#if>
<#if abstractProp?has_content && abstractProp.statements?has_content>
	<#assign abstractStmt = abstractProp.statements?first />
	<#assign abstract >
		<h3 style="color:#CC6949;font-size:17px;padding:16px 0 8px 0;text-align:center">Abstract</h3>
		<div style="color:#595b5b;font-size:16px;padding:2px 2px 0 12px">
			${abstractStmt.value!}
		</div>
	</#assign>
</#if>
<#if authorsProp?has_content && authorsProp.statements?has_content>
	<#assign authorList>
		<div class="col-sm-12" style="background-color:#fff;padding:6px 0 0 4px;">
		  <div class="col-sm-1" style="text-align:right;padding:0 0 0 0;">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Authors</h3>
		  </div>
		  <div class="col-sm-9" style="padding:2px 0 0 4px">
			<div class="scholars-article-metadata">
			<#list authorsProp.statements as statement>
				<span style="padding-right:8px">
		    	<#if statement.subclass?? && statement.subclass?contains("vcard")>
					<#if statement.authorName?replace(" ","")?length == statement.authorName?replace(" ","")?last_index_of(",") + 1 >
		        		${statement.authorName?replace(",","")}
					<#else>
						${statement.authorName}<#if statement_has_next>,</span><#else></span></#if>
					</#if>
		    	<#else>
		        	<a href="${profileUrl(statement.uri("author"))}" title="${i18n().author_name}">${statement.authorName}</a><#if statement_has_next>,</span><#else></span></#if>
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
		<div class="col-sm-12" style="padding:6px 0 0 4px;">
		  <div class="col-sm-1" style="text-align:right;padding:0 0 0 4px">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Journal</h3>
		  </div>
		  <div class="col-sm-9" style="padding:2px 0 0 2px">
			<div class="scholars-article-metadata">
				<em><a href="${profileUrl(pubVenue.object)}" title="${pubVenue.label!}">${pubVenue.label!}</a></em>
				<#if lcp??><a href="${lcp}" target="_blank"><i class="fa fa-external-link-square" aria-hidden="true" style="margin:0 0 0 8px;color:#609bc1"></i></a></#if>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if volumeProp?has_content && volumeProp.statements?has_content>
	<#assign volumeStmt = volumeProp.statements?first />
	<#assign volume >
		<div style="margin-left:24px;display:inline-block;width:80%">
			<h3 style="color:#CC6949;font-size:17px;padding:2px 0 6px 0;display:inline-block;width:100px;text-align:right">Volume</h3><div class="scholars-article-metadata">${volumeStmt.value!}</div>
		</div>
	</#assign>
</#if>
<#if issueProp?has_content && issueProp.statements?has_content>
	<#assign issueStmt = issueProp.statements?first!""/>
	<#assign issue >
		<div style="margin-left:24px;display:inline-block;width:80%">
			<h3 style="color:#CC6949;font-size:17px;padding:2px 0 6px 0;display:inline-block;width:100px;text-align:right">Issue</h3><div class="scholars-article-metadata">${issueStmt.value!}</div>
		</div>
	</#assign>
</#if>
<#if volume?has_content && issue?has_content >
	<#assign volumeIssue>
		  <div class="col-sm-9" style="text-align:right;padding:6px 0 0 0">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Volume(Issue)</h3>
		  </div>
		  <div class="col-sm-3" style="padding:8px 0 0 0">
			<div class="scholars-article-metadata">
				${volumeStmt.value!}(${issueStmt.value!})
			</div>
		  </div>
	</#assign>
<#elseif volume?has_content && !issue?has_content >
	<#assign volumeIssue>
		  <div class="col-sm-9" style="text-align:right;padding:6px 0 0 0">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Volume</h3>
		  </div>
		  <div class="col-sm-3" style="padding:2px 0 0 0">
			<div class="scholars-article-metadata">
				${volumeStmt.value!}
			</div>
		  </div>
	</#assign>
<#elseif !volume?has_content && issue?has_content >
	<#assign volumeIssue>
		  <div class="col-sm-9" style="text-align:right;padding:6px 0 0 0">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Issue</h3>
		  </div>
		  <div class="col-sm-3" style="padding:2px 0 0 0">
			<div class="scholars-article-metadata">
				${issueStmt.value!}
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
		<div class="col-sm-12" style="padding:6px 0 0 0;">
		  <div class="col-sm-1" style="text-align:right;padding:0 0 0 15px">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Pages</h3>
		  </div>
		  <div class="col-sm-9" style="padding:2px 0 0 7px">
			<div class="scholars-article-metadata">
				${startPage!} - ${endPage!}
			</div>
		  </div>
		</div>
	</#assign>
<#elseif startPage?has_content && !endPage?has_content >
	<#assign pages>
		<div class="col-sm-12" style="padding:6px 0 0 0">
		  <div class="col-sm-1" style="text-align:right;padding:0 0 0 15px">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Starts</h3>
		  </div>
		  <div class="col-sm-9" style="padding:2px 0 0 7px">
			<div class="scholars-article-metadata">
				${startPage!}
			</div>
		  </div>
		</div>
	</#assign>
<#elseif !startPage?has_content && endPage?has_content >
	<#assign pages>
		<div class="col-sm-12" style="padding:6px 0 0 0;">
		  <div class="col-sm-1" style="text-align:right;padding:0 0 0 15px">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Ends</h3>
		  </div>
		  <div class="col-sm-9" style="padding:2px 0 0 7px">
			<div class="scholars-article-metadata">
				${endPage!}
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if pubDate?has_content>
	<#assign published ><span style="font-size:20px">(${pubDate!})</span></#assign>
	<#assign publishedInline >
		  <div class="col-sm-9" style="text-align:right;padding:6px 0 0 0">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Published</h3>
		  </div>
		  <div class="col-sm-3" style="padding:8px 0 0 0">
			<div class="scholars-article-metadata">
				${pubDate!}
			</div>
		  </div>
	</#assign>

</#if>
<#if gccProp?has_content && gccProp.statements?has_content >
	<#assign gcc>
		  <div class="col-sm-9" style="text-align:right;padding:6px 0 0 0">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Citations</h3>
		  </div>
		  <div class="col-sm-3" style="padding:9px 0 0 0">
			<div class="scholars-article-metadata">
				&nbsp;${gccProp.statements[0].count!}
			</div>
		  </div>
	</#assign>
</#if>
<#if doiProp?has_content && doiProp.statements?has_content>
	<#assign doiStmt = doiProp.statements?first!""/>
	<#assign doi = doiStmt.value! />
	<#assign doiInline>
		<div class="col-sm-3" style="text-align:right;padding:0 0 0 0;">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">DOI</h3>
		</div>
		<div class="col-sm-9" style="padding:0 0 0 0;margin-top:-3px">
			<div style="color:#595b5b;font-size:<#if (doi?length! > 30) && abstract?has_content>15<#else>16</#if>px;padding-left:15px">
				<a href="http://dx.doi.org/${doi!}" title="link to DOI" target="_blank">${doi!}</a>
			</div>
		</div>
	</#assign>
</#if>
<#if pmidProp?has_content && pmidProp.statements?has_content>
	<#assign pmidStmt = pmidProp.statements?first!""/>
	<#assign pmid = pmidStmt.value! />
	<#assign pmidInline>
		<div class="col-sm-3" style="text-align:right;padding:0 0 0 0;">
			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">PMID</h3>
		</div>
		<div class="col-sm-9" style="padding:0 0 0 0;margin-top:-3px">
			<div class="scholars-article-metadata">
				<a href="http://www.ncbi.nlm.nih.gov/pubmed/?term=${pmid!}" title="View in PubMed" target="_blank">${pmid!}</a>
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
		<div class="col-sm-3" style="text-align:right;padding:0 0 0 0;">
  			<h3 style="color:#CC6949;font-size:17px;padding:0 0 0 0">Keywords</h3>
		</div>
		<div class="col-sm-9" style="padding:0 0 0 0;margin-top:-3px">
  			<div style="color:#595b5b;font-size:16px;padding-left:18px">
  				<ul>
  					<#list keywordsProp.statements as statement>
  						<li class="list-item">
  							${statement.value!}.<#-- if statement_has_next>,</#if -->
  						</li>
  					</#list>
  				</ul>
  			</div>
		</div>
	</#assign>
</#if>
<#-- The row1 div contains the top portion of the profile page: tile, icon controls, authors, key metadata -->
<div id="row1" class="row" style="background-color:#f1f2f3">
<div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="biboDocumentMainColumn">

<section id="individual-info" ${infoClass!} role="region">
    <#include "individual-adminPanel.ftl">

    <#if individualProductExtensionPreHeader??>
        ${individualProductExtensionPreHeader}
    </#if>
	
    <header>
			<#include "individual-altmetric.ftl">
            <h1 class="fn" itemprop="name" style="margin-top:17px;float:left;margin-left:24px;width:72%">
                <#-- Label -->
                <@p.label individual editable labelCount localesCount languageCount/>
                <#--  Most-specific types -->
                <@p.mostSpecificTypes individual />
            </h1>
		<div style="float:right;margin:14px 10px -14px 0">
			<#include "document-iconControls.ftl" />
		</div>

		<h2 id="relatedBy" class="mainPropGroup" title="A position, either vertical or horizontal." style="margin-left:24px;clear:both;padding-top:0;border-bottom:1px solid #b9b9b9">  </h2>
    </header>
	<div class="row" role="row" style="background-color:#fff;margin-left:24px">
		<div class="col-sm-9 col-md-9 col-lg-9">
			<div class="row" role="row" style="background-color:#fff">
				${authorList?replace(" ,",",")!}
			</div>
			<div class="row" role="row" style="background-color:#fff">
				${journalTitle!}
			</div>
			<div class="row" role="row" style="background-color:#fff">
				${pages!}
			</div>
			<div class="row" role="row" style="background-color:#fff">
				
			</div>
		</div>

		<div class="col-sm-2 col-md-2 col-lg-2">
			<div class="row" role="row" style="background-color:#fff">
				${gcc!}
			</div>
			<div class="row" role="row" style="background-color:#fff">
				${volumeIssue!}
			</div>
			<div class="row" role="row" style="background-color:#fff">
				${publishedInline!}
			</div>
		</div>
	</div>


	<#--		
			${doiInline!} -->
		
		
        </section> <!-- individual-info -->
		<div style="clear:both;padding-top:12px"></div>

	</div> <!-- biboDocumentMainColumn -->
</div> <!-- row1 -->
<#if abstract?has_content || keywordsList?has_content || doiInline?has_content || pmidInline?has_content >
	<div id="row2" class="row" style="background-color:#f1f2f3;margin-top:30px" >
	<#if abstract?has_content>
		<div id="keywords" class="col-sm-5 col-md-5 col-lg-5 scholars-container">
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
				${keywordsList!}
			</div>
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
				${doiInline!}
			</div>
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
				${pmidInline!}
			</div>
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
			</div>
		</div>
		<div class="col-sm-1 col-md-1 col-lg-1"></div>
		<div id="abstract" class="col-sm-6 col-md-6 col-lg-6 scholars-container">
			${abstract!}
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
			</div>
		</div> 
	<#else>
		<div id="foafPersonViz" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
			<div class="row" style="background-color:#fff;margin:16px 0 0 0" >
				<div class="col-sm-12 col-md-12 col-lg-12">
					<div class="row" style="background-color:#fff;margin:16px 0 0 0">
						<div class="col-sm-5 col-md-5 col-lg-5" style="margin-bottom:16px">
							${keywordsList!}
						</div>
						<div class="col-sm-1 col-md-1 col-lg-1" ></div>
						<div class="col-sm-5 col-md-5 col-lg-5">
							<div class="row" style="background-color:#fff;margin:0 0 0 0">
								${doiInline!}
							</div>
							<div class="row" style="background-color:#fff;margin:16px 0 0 0">
								${pmidInline!}
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
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

<div class="row" style="margin-bottom:400px"></div>

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

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />',
				  '<link rel="stylesheet" href="${urls.base}/css/individual/individual.css?vers=1.5.1" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}
