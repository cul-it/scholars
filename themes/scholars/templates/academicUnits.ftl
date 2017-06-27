<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">
<#assign collegeCount = 0 />
<#assign schoolCount = 0 />
<#assign departmentCount = 0 />
<#assign libraryCount = 0 />
<#assign instituteCount = 0 />
<#if mstFacet?? >
	<#list mstFacet?keys as key >
		<#if key?contains("College")>
			<#assign collegeCount = mstFacet[key] />
		<#elseif key?contains("School")>
			<#assign schoolCount = mstFacet[key] />
		<#elseif key?contains("Department")>
			<#assign departmentCount = mstFacet[key] />
		<#elseif key?contains("Library")>
			<#assign libraryCount = mstFacet[key] />
		<#elseif key?contains("Institute")>
			<#assign instituteCount = mstFacet[key] />
		</#if>
	</#list>
</#if>
<h2 class="expertsResultsHeader">Browse Academic Units</h2>
<div id="search-field-container" class="contentsBrowseGroup row fff-bkg" style="margin-bottom:15px">
  <div class="col-md-5">
    <fieldset>
        <legend>${i18n().search_form}</legend>
		<form id="units-search-form" action="${urls.base}/academicUnits" name="search" role="search" accept-charset="UTF-8" method="POST"> 
			<input id="units-search-vclass" type="hidden" name="vclassId" value="http://xmlns.com/foaf/0.1/Organization" />
			<input id="units-search-querytype" type="hidden" name="querytype" value="${querytype!}" />
			<input id="units-search-input" class="results-input" type="text" name="querytext" value="${querytext!}" placeholder="Quick search: enter a full or partial name"/>
			<input id="results-search-submit" type="submit" action="${urls.base}/academicUnits?origin=homepage" value="GO"/>
		</form>
    </fieldset>
  </div>
<#if  !individuals?? && message?? && message == "new_search">
<div id="no-results-container" class="col-md-6">
	<div id="results-container" class="panel panel-default new-search">
		<div id="no-results-text">
			<div class="no-results-found">Locate domain experts by subject or keyword, or by the person's name.</div>
			<div class="no-results-found">Enter your own search term or select one from the list of suggestions.</div>
		</div>
	</div>
</div>
<#elseif  !individuals??>
	<div id="no-results-container" class="col-md-6">
		<div id="results-container" class="panel panel-default no-results">
      		<div id="no-results-text">
				<#if message?? && message == "no_matches">
					<div class="no-results-found">No results matched the term:</div>
					<div id="unmatched-term"><span>'${badquerytext!}'</span></div>
					<div class="no-results-found">Try another term or select one from the list of suggestions.</div>
				<#elseif  message?? && message == "no_search_term">
					<div class="no-results-found">Please enter a search term or select one from the list of suggestions.</div>
				<#else>
					<div class="no-results-found">Your search for the term '${badquerytext!}' did not complete successfully.</div>
					<div class="no-results-found">Try another term or select one from the list of suggestions.</div>
				</#if>
			</div>
        </div>
	</div>
</#if>
</div>
<#if individuals?? >
  <div id="facets-and-results" class="contentsBrowseGroup row fff-bkg">
  <div id="facet-container" class="col-md-3" style="padding-right:0">
        <div id="position-facets" class="panel panel-default selection-list" >
                <div class="panel-heading facet-panel-heading">Unit Type</div>
				<#assign classCount = 0 />
            	<div class="panel-body scholars-facet">
				  <label>
					<input type="radio" style="margin:0 0 0 -18px;" name="querytype" value="colleges" <#if querytype == "colleges">checked</#if>/> Colleges<span> (${collegeCount!}) </span>
				  </label>
				</div>
            	<div class="panel-body scholars-facet">
				  <label>
					<input type="radio" style="margin:10px 0 0 -18px;" name="querytype" value="schools" <#if querytype == "schools">checked</#if> /> Schools<span> (${schoolCount!}) </span>
				  </label>
				</div>
            	<div class="panel-body scholars-facet">
				  <label>
					<input type="radio" style="margin:10px 0 0 -18px;" name="querytype" value="departments" <#if querytype == "departments">checked</#if> /> Academic Departments<span> (${departmentCount!}) </span>
				  </label>
				</div>
            	<div class="panel-body scholars-facet">
				  <label>
					<input type="radio" style="margin:10px 0 0 -18px;" name="querytype" value="libraries" <#if querytype == "libraries">checked</#if> /> Libraries<span> (${libraryCount!}) </span>
				  </label>
				</div>
            	<div class="panel-body scholars-facet">
				  <label>
					<input type="radio" style="margin:10px 0 0 -18px;" name="querytype" value="institutes" <#if querytype == "institutes">checked</#if> /> Institutes<span> (${instituteCount!}) </span>
				  </label>
				</div>
        </div>
    <div id="jump-check"></div>
  </div>
  <p id="jump-to-page-top" class="pull-right">
	<img class="jump-to-top" title="jump to top of page" alt="arrow up" data-no-retina="" src="${urls.base}/themes/scholars/images/jump-to-top.gif">
  </p>

 	<!-- facet container -->
	<#if querytype == "colleges" >
			<div class="col-md-9" style="text-align:right;padding-right: 60px;margin-top:-30px">
				<a id="show-all-children" href="javascript:" style="font-size:14px" data-state="hidden">show all departments/schools</a>
				<i class="fa fa-caret-down" aria-hidden="true"></i>
			</div>
	</#if>
    <div id="results-column" class="col-md-9">
	  <div id="results-container" class="panel panel-default">
	    <#if (hitCount > 20) && alphaList?has_content>
	      <div class="panel-heading" style="width:100%;background-color:#394e6b;padding:10px 0 10px 0;">
			<ul id="alpha-browse" style="padding-left:20px;" >
				<li style="color:#fff;display:inline;font-size:14px;padding-right:20px;"><a id="all-link" href="javascript:" data-qtype="${querytype!}" class="active-browse-links browse-links">All ${querytype?capitalize!}</a></li>
				<#list alphaList as ltr >
					<li style="color:#fff;display:inline;padding-right:15px;">
						<a href="javascript:" id="nav-${ltr!}" data-letter="${ltr!}" class="browse-links">${ltr!}</a>
					</li>
				</#list>
			</ul>
		  </div>
		</#if>
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
</#if>
  </div> <!--! end of #container -->
</div> <!-- end of row -->
<#if !querytext?has_content >
<script>
	$(document).ready(function() {
		$('.mst-display').remove();
	});
</script>
</#if>

${stylesheets.add('<link rel="stylesheet" href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />',
  				  '<link rel="stylesheet" href="${urls.base}/css/search.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/searchDownload.js"></script>')}
<script>
var baseUrl = "${urls.base}";
var imagesUrl = "${urls.images}";
</script>
${scripts.add('<script type="text/javascript" src="${urls.base}/js/academicUnits.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.scrollTo-min.js"></script>')}
