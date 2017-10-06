<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">
<#assign hasPubs = false />
<#assign hasGrants = false />
<#assign hasContracts = false />
<#assign disableAll = false />
<#if individuals?? >
	<#assign searchResults>
		<#escape x as x?html>
			<span>${hitCount} item<#if (hitCount > 1)>s</#if> found.</span>
		</#escape>
	</#assign>
	<#if (pubCount > 0) >
		<#assign hasPubs = true />
	</#if>
	<#if (grantCount > 0) >
		<#assign hasGrants = true />
	</#if>
	<#if (contractCount > 0) >
		<#assign hasContracts = true />
	</#if>
	<#assign grantContractTotal = (grantCount + contractCount) />
</#if>
<#-- If we only have pubs or we only have grants, set the querytype accordingly -->
<#if !querytype?? >
	<#assign adjQueryType = "all" />
<#elseif querytype == "pubs" || (pubCount > 0 && grantContractTotal == 0) >
	<#assign adjQueryType = "pubs" />
<#elseif querytype == "grants" || (grantContractTotal > 0 && pubCount == 0) >
	<#assign adjQueryType = "grants" />
<#else>
	<#assign adjQueryType = "all" />
</#if>
<#if querytext?? >
	<#assign querytext = querytext?replace("\"","&quot;")/>
<#else>
	<#assign querytext = ""/>
</#if>

<h2 class="expertsResultsHeader">Explore Research & Scholarship</h2>
<div id="search-field-container" class="contentsBrowseGroup row fff-bkg">
  <div class="col-md-5">
    <fieldset>
        <legend>${i18n().search_form}</legend>
		<form id="results-search-form" action="${urls.base}/scholarship" name="search" role="search" accept-charset="UTF-8" method="POST"> 
			<input id="de-search-vclass" type="hidden" name="vclassId" value="http://purl.obolibrary.org/obo/BFO_0000002" />
			<input id="res-search-input" class="results-input" type="text" name="querytext" value="${querytext!}"/>
			<input id="results-search-submit" type="button" value="GO"/>
			<input id="hidden-querytype" type="hidden" name="querytype" value="${adjQueryType!}" />
			<input type="hidden" name="unselectedRadio" value="" />
			<input type="hidden" name="radioCount" value="" />
		</form>
		<#-- we need these values for the ajax call that happens on scrolling and faceting. can't use the values in the form -->
		<#-- because, though unlikely, users could clear the query text or change the query type, change their mind and      -->
		<#-- continue scrolling or clicking facets. Deal with it, Hudson.                                                    -->
		<input id="hidden-querytext" type="hidden" name="q-text" value="${querytext!}" />
    </fieldset>
  </div>
<#if individuals?? >
  <div id="start-over" class="col-md-6">
	<a id="start-over-link" href="javascript:return false;" title="Click to begin a new search">Start over</a>
  </div>
<#elseif  message?? && message == "new_search">
<div id="no-results-container" class="col-md-6">
	<div id="results-container" class="panel panel-default new-search">
		<div id="no-results-text">
			<div class="no-results-found">Locate domain experts by subject or keyword, or by the person's name.</div>
			<div class="no-results-found">Enter your own search term or select one from the list of suggestions.</div>
		</div>
	</div>
</div>
<#else>
	<div id="no-results-container" class="col-md-6">
		<div id="results-container" class="panel panel-default no-results">
      		<div id="no-results-text">
				<#if message?? && message == "no_matches">
					<div class="no-results-found">No results matched the term:</div>
					<div id="unmatched-term"><span>'${badquerytext!}'</span></div>
					<div class="no-results-found">Try selecting another term from the list of suggestions. Or</div>
					<div><a class="scholars-button" href="${urls.base}/search?querytext=${badquerytext!}">Search the full site</a></div>
				<#elseif  message?? && message == "no_search_term">
					<div class="no-results-found">Please enter a search term or select one from the list of suggestions.</div>
				<#else>
					<div class="no-results-found">Your search for the term '${badquerytext!}' did not complete successfully.</div>
					<div class="no-results-found">Try selecting another term from the list of suggestions. Or<br/><a class="scholars-button" href="${urls.base}/search?querytext=${badquerytext!}">Search the full site</a></div>
				</#if>
			</div>
        </div>
	</div>
</#if>
</div>
<#if individuals?? >
  <#if unselectedRadio?has_content >
	<#if unselectedRadio == "pubs">
		<#if (radioCount?string !=  "0") >
			<#assign hasPubs = true />
			<#assign pubCount = radioCount />
		</#if>
	<#elseif unselectedRadio == "grants">
		<#if (radioCount?string !=  "0") >
			<#assign hasGrants = true />
			<#assign grantContractTotal = radioCount />
		</#if>
    </#if>
  </#if>
<#if (pubCount?string?replace(",","")?number == 0 || grantContractTotal?string?replace(",","")?number == 0) >
	<#assign disableAll = true />
</#if>
  <div id="research-radios-results" class="row fff-bkg">
	<div id="research-radio-container" class="col-md-4">
		<input id="all-radio" class="research-radio" type="radio" name="querytype" value="all" <#if adjQueryType == "all">checked</#if> <#if disableAll> disabled</#if>>
		<label for="all-radio"> All</label>
		<input id="pubs-radio" class="research-radio" type="radio" name="querytype" data-count="${pubCount!}" value="pubs" <#if adjQueryType == "pubs">checked</#if><#if !hasPubs> disabled</#if>>
		<label for="pubs-radio"> Publications (${pubCount!})</label>
		<input id="grants-radio" class="research-radio" type="radio" name="querytype" data-count="${grantContractTotal!}" value="grants" <#if adjQueryType == "grants">checked</#if><#if !hasGrants && !hasContracts> disabled</#if>>
		<label for="grants-radio"> Grants (${grantContractTotal!})</label>
	</div>
	
  	<div id="results-blurb" class="col-md-4">
		${searchResults!}
  	</div>
  	<div id="search-sort-by" class="col-md-4">
		Sort by
		<select id="sort-results">
			<option value="relevance">relevance</option>
			<option value="title">title</option>
		</select/>
  	</div>
  </div>
  <div id="facets-and-results" class="contentsBrowseGroup row fff-bkg">
  <div id="facet-container" class="col-md-4">
    <#if (classFacet?has_content && adjQueryType != "all")>
        <div id="position-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Type</div>
				<#assign classCount = 0 />
            <#list classFacet as class>
                	<div class="panel-body scholars-facet">
						<#assign vclassid = class.url[class.url?index_of("vclassId=")+9..] />
						<label>
							<input type="checkbox" class="type-checkbox position-cb" data-vclassid="${vclassid?url}" value="${class.text}"/> ${class.text}<span> (${class.count})</span>
						</label>
					</div>
					<#assign classCount = classCount + class.count?number />
            </#list>
        </div>
    </#if>
    <#if affiliationFacet?has_content>
        <div id="affiliation-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Affiliation</div>
				<#assign affilCount = 0 />
            <#list affiliationFacet?keys as key>
                <div class="panel-body scholars-facet">
					<label>
						<input type="checkbox" class="type-checkbox affiliation-cb" data-affiliation="${key}" /> ${key}<span> (${affiliationFacet[key]})</span>
					</label>
				</div>
				<#assign affilCount = affilCount?string?replace(",","")?number + affiliationFacet[key]?string?replace(",","")?number />
            </#list>
			<#if (affilCount > hitCount?string?replace(",","")?number)>
				<div class="facet-note" data-ac="${affilCount?string?replace(",","")?number}" data-hc="${hitCount?string?replace(",","")?number}">* Some scholars may have multiple affiliations.</div>
			</#if>
        </div>
    </#if>
    <#if pubVenueFacet?has_content && adjQueryType == "pubs">
        <div id="pubvenue-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Publication Venue</div>
				<div class="inner-facets-container">
            	<#list pubVenueFacet?keys as key>
                	<div class="panel-body scholars-facet">
						<label>
							<input type="checkbox" class="type-checkbox pubvenue-cb" data-pubvenue="${key}" /> ${key}<span> (${pubVenueFacet[key]})</span>
						</label>
					</div>
            	</#list>
				</div>
        </div>
    </#if>
    <#if administratorFacet?has_content && adjQueryType == "grants" >
        <div id="administrator-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Administered by</div>
				<div class="inner-facets-container">
            	<#list administratorFacet?keys as key>
                	<div class="panel-body scholars-facet">
						<label>
							<input type="checkbox" class="type-checkbox administrator-cb" data-administrator="${key}" /> ${key}<span> (${administratorFacet[key]})</span>
						</label>
					</div>
            	</#list>
				</div>
        </div>
    </#if>
    <#if funderFacet?has_content && adjQueryType == "grants">
        <div id="funder-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Funding Agency</div>
				<div class="inner-facets-container">
            	<#list funderFacet?keys as key>
                	<div class="panel-body scholars-facet">
						<label>
							<input type="checkbox" class="type-checkbox funder-cb" data-funder="${key}" /> ${key?capitalize?replace("Nsf","NSF")?replace("Nih","NIH")?replace("Dhhs","DHHS")?replace("usda","USDA")?replace("Usda","USDA")?replace("A&m","A&M")?replace("Doe","DOE")?replace("Dod","DOD")?replace("Rsch","RSCH")?replace("Res","RES")?replace("Ltd","LTD")?replace("Fdn","FDN")?replace("Doi","DOI")?replace("Gsa","GSA")?replace("Doc","DOC")?replace(" Us"," US")}<span> (${funderFacet[key]})</span>
						</label>
					</div>
            	</#list>
				</div>
        </div>
    </#if>
    <#if (startYear?has_content && endYear?has_content && adjQueryType != "all")>
		<script>
			var startYear = ${startYear?c!};
			var endYear = ${endYear?c!};
		</script>
        <div id="yearRange-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading"><#if adjQueryType == "pubs">Publication<#else>Active</#if> Year</div>
				<div class="inner-facets-container">
                	<div class="panel-body scholars-facet">
					  <#if adjQueryType == "grants">
						<div id="reset-dates" class="search-date-reset">
							<a id="reset-dates-link" href="javascript:return false;">Reset</a>
						</div>
					  </#if>
						<div id="slider" class="search-date-slider"></div>
						<#if adjQueryType == "grants">
							<div id="search-pips">
								<div class="pull-left">|</div><div class="pull-right">|</div>
							</div>
							<div id="demarcation">
								<span id="date-start" data-date="${startYear?c!}" class="pull-left">${startYear?c!}</span><span id="date-end" data-date="${endYear?c!}" class="pull-right">${endYear?c!}</span>
							</div>
						</#if>
					</div>
				</div>
        </div>
	<#else>
		<script>
			var startYear = 0;
			var endYear = 0;
		</script>
    </#if>
    <div id="jump-check"></div>
  </div>
  <p id="jump-to-page-top" class="pull-right">
	<img class="jump-to-top" title="jump to top of page" alt="arrow up" data-no-retina="" src="${urls.base}/themes/scholars/images/jump-to-top.gif">
  </p>

 	<!-- facet container -->
    <div id="results-column" class="col-md-8">
	  <div id="results-container" class="panel panel-default">
      <ul class="searchhits">
			<li id="time-indicator">
				<img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
				<p>Searching</p>
			</li>
  			<#list individuals as indy>
  				${indy!}
  			</#list>
  			<#assign adjPage = (currentPage + 1) />
  			<#assign adjStartIndex =  (adjPage * hitsPerPage) />
  			<#if ( hitCount > adjStartIndex ) >
  				<li id="scroll-control" data-start-index="${adjStartIndex}" data-current-page="${adjPage}">
  					<img id="search-indicator" src="${urls.images}/indicatorWhite.gif" /> 
  					<span>retrieving additional results</span>
  				</li>
  			</#if>
      </ul>
      </div>
    </div>  
</div>
</div> <!-- end contentsBrowseGroup -->
<#else>
	<script>
		var startYear = 0;
		var endYear = 0;
	</script>
</#if>
  </div> <!--! end of #container -->
</div> <!-- end of row -->

${stylesheets.add('<link rel="stylesheet" href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />',
				  '<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/grants/nouislider.min.css">',
  				  '<link rel="stylesheet" href="${urls.base}/css/search.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/searchDownload.js"></script>')}
<script>
var baseUrl = "${urls.base}";
var imagesUrl = "${urls.images}";
</script>
${scripts.add('<script type="text/javascript" src="${urls.base}/js/exploreResearch.js"></script>',
			  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/nouislider.min.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.scrollTo-min.js"></script>')}
<#-- @dumpAll/ -->
