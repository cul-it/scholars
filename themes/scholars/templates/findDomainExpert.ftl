<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">

<h2 class="searchResultsHeader">Find Domain Experts</h2>
<#if individuals?? >
	<#assign searchResults>
		<#escape x as x?html>
    		<span>${hitCount} scholar<#if (hitCount > 1)>s</#if> found.</span>
		</#escape>
	</#assign>
</#if>
<div id="search-field-container" class="contentsBrowseGroup row fff-bkg">
  <div class="col-md-5">
    <fieldset>
        <legend>${i18n().search_form}</legend>
		<#assign qType = querytype!"subject" />
		<form id="results-search-form" action="${urls.base}/domainExpert" name="search" role="search" accept-charset="UTF-8" method="POST"> 
			<input id="de-search-vclass" type="hidden" name="vclassId" value="http://xmlns.com/foaf/0.1/Person" />
			<input id="de-search-input" class="results-input <#if qType == "name">name-search<#else>subject-search</#if>" type="text" name="querytext" value="${querytext!}"/>
			<input id="results-search-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="Go"/>
			<div class="results-search-radio-container">
				<input type="radio" name="querytype" value="subject" <#if qType == "subject">checked</#if>> by subject or keyword
	   			<input id="by-name-radio" type="radio" name="querytype" value="name" <#if qType == "name">checked</#if>> by name
	  		</div>
		</form>
		<#-- we need these values for the ajax call that happens on scrolling and faceting. can't use the values in the form -->
		<#-- because, though unlikely, users could clear the query text or change the query type, change their mind and      -->
		<#-- continue scrolling or clicking facets. Deal with it, Hudson.                                                    -->
		<input id="hidden-querytext" type="hidden" name="q-text" value="${querytext!}" />
		<input id="hidden-querytype" type="hidden" name="q-type" value="${querytype!}" />
    </fieldset>
  </div>
<#if individuals?? >
  <div id="start-over" class="col-md-6">
	<a id="start-over-link" href="#" title="Click to begin a new search">Start over</a>
  </div>
<#else>
	<div id="no-results-container" class="col-md-6">
		<div id="results-container" class="panel panel-default no-results" style="">
      		<div id="no-results-text">
				<#if message?? && message == "no_matches">
					<div class="no-results-found">No results matched the term:</div>
					<div id="unmatched-term"><span>'${title!}'</span></div>
					<div class="no-results-found">Try another term or select one from the list of suggestions.</div>
				<#else>
					<#assign str = title + "test"/>
					<#if str == "test" >
						<div class="no-results-found">Please enter a search term or select one from the list of suggestions.</div>
					<#else>
						<div class="no-results-found">Your search for the term '${title!}' did not complete successfully.</div>
						<div class="no-results-found">Try another term or select one from the list of suggestions.</div>
					</#if>
				</#if>
			</div>
      </div>
</#if>
</div>
<#if individuals?? >
  <div id="facets-and-results" class="contentsBrowseGroup row fff-bkg">
  <div id="facet-container" class="col-md-4">
    <#if classFacet?has_content>
        <div id="position-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Position</div>
            <#list classFacet as class>
				<#if class.text != "Person" >
                	<div class="panel-body scholars-facet">
						<#assign vclassid = class.url[class.url?index_of("vclassId=")+9..] />
						<label>
							<input type="checkbox" class="type-checkbox position-cb" data-vclassid="${vclassid?url}" value="${class.text}"/> ${class.text}<span> (${class.count})</span>
						</label>
					</div>
				</#if>
            </#list>
        </div>
    </#if>
    <#if collegeFacet?has_content>
        <div id="college-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">College / School</div>
            <#list collegeFacet?keys as key>
                <div class="panel-body scholars-facet">
					<label>
						<input type="checkbox" class="type-checkbox college-cb" data-college="${key}" /> ${key}<span> (${collegeFacet[key]})</span>
					</label>
				</div>
            </#list>
        </div>
    </#if>
    <#if departmentFacet?has_content>
        <div id="department-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Department</div>
            <#list departmentFacet?keys as key>
                <div class="panel-body scholars-facet">
					<label>
						<input type="checkbox" class="type-checkbox department-cb" data-department="${key}" /> ${key}<span> (${departmentFacet[key]})</span>
					</label>
				</div>
            </#list>
        </div>
    </#if>
  </div> <!-- facet container -->
    <div id="results-column" class="col-md-8">
	  <div id="results-blurb">
		${searchResults!}
	  </div>
	  <div id="results-container" class="panel panel-default">
      <ul class="searchhits">
  			<#list individuals as indy>
  				${indy!}
  			</#list>
  			<#assign adjPage = (currentPage + 1) />
  			<#assign adjStartIndex =  (adjPage * hitsPerPage) />
  			<#if ( hitCount > adjStartIndex ) >
  				<li id="scroll-control" data-start-index="${adjStartIndex}" data-current-page="${adjPage}">
  					<img id="search-indicator" src="${urls.images}/indicatorWhite.gif" /> 
  					<spa>retrieving additional results</span>
  				</li>
  			</#if>
  			<script>
  				console.log("INITIAL START INDEX = " + "${adjStartIndex}");
  				console.log("INITIAL PAGE ADJ = " + "${adjPage}");
  			</script>
      </ul>
      </div>
    </div>  
</div>
</div> <!-- end contentsBrowseGroup -->
</#if>
  </div> <!--! end of #container -->
</div> <!-- end of row -->

${stylesheets.add('<link rel="stylesheet" href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />',
  				  '<link rel="stylesheet" href="${urls.base}/css/search.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/searchDownload.js"></script>')}
<script>
var baseUrl = "${urls.base}";
var imagesUrl = "${urls.images}";
</script>
${scripts.add('<script type="text/javascript" src="${urls.base}/js/findDomainExpert.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.scrollTo-min.js"></script>')}
<#-- @dumpAll/ -->
