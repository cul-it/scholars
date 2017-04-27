<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">

<h2 class="searchResultsHeader">
<#escape x as x?html>
    ${i18n().search_results_for} '${querytext!""}'
    <#if classGroupName?has_content>${i18n().limited_to_type} '${classGroupName}'</#if>
    <#if typeName?has_content>${i18n().limited_to_type} '${typeName}'</#if>
</#escape>
<script type="text/javascript">
	var url = window.location.toString();	
	if (url.indexOf("?") == -1){
		var queryText = 'querytext=${querytext!""}';
	} else {
		var urlArray = url.split("?");
		var queryText = urlArray[1];
	}
	
	var urlsBase = '${urls.base}';
</script>

</h2>

<div class="contentsBrowseGroup row fff-bkg" style="margin-bottom:20px">
  <div class="col-md-12">
    <fieldset>
        <legend>${i18n().search_form}</legend>
		<#assign qType = querytype!"subject" />
		<form id="results-search-form" action="${urls.base}/domainExpert" name="search" role="search" accept-charset="UTF-8" method="POST"> 
			<input id="de-search-vclass" type="hidden" name="vclassId" value="http://xmlns.com/foaf/0.1/Person" />
			<input id="de-search-input" class="<#if qType == "name">name-search<#else>subject-search</#if>" type="text" name="querytext" value="${querytext!}" style="width:300px" />
			<input id="results-search-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="Go" />
			<div class="results-search-radio-container">
				<input type="radio" name="querytype" value="subject" <#if qType == "subject">checked</#if>> by subject or keyword
	   			<input id="by-name-radio" type="radio" name="querytype" value="name" <#if qType == "name">checked</#if>> by name
	  		</div>
		</form>
		<#-- we need these values for the ajax call that happens on scrolling and faceting. can't use the values in the form -->
		<#-- because, though unlikely, users could clear the query text or change the query type, change their mind and      -->
		<#-- continue scrolling or clicking facets. Deal with it, Hudson.                                                    -->
		<input id="hidden-querytext" type="hidden" name="q-text" value="${querytext}" />
		<input id="hidden-querytype" type="hidden" name="q-type" value="${querytype}" />
    </fieldset>
  </div>
</div>
<div class="contentsBrowseGroup row fff-bkg">
  <div id="facet-container" class="col-md-3">

    <#if classLinks?has_content>
        <div class="panel panel-default selection-list" >
                <div class="panel-heading" style="line-height:18px;font-size:16px">Position</div>
            <#list classLinks as link>
                <div class="panel-body" style="padding:10px;line-height:16px;font-size:14px">
					<#if link.text != "Person" >
						<#assign vclassid = link.url[link.url?index_of("vclassId=")+9..] />
						<input type="checkbox" class="type-checkbox" data-vclassid="${vclassid?url}" /> ${link.text}<span> (${link.count})</span>
					</#if>
				</div>
            </#list>
        </div>
    </#if>
  </div>
  <div id="results-container" class="col-md-8 panel panel-default ">
    <#-- Search results -->
	<#if individuals?? >
    <ul class="searchhits">
			<#list individuals as indy>
				${indy!}
			</#list>
			<#assign adjPage = (currentPage + 1) />
			<#assign adjStartIndex =  (adjPage * hitsPerPage) />
			<#if ( hitCount > adjStartIndex ) >
				<li id="scroll-control" data-start-index="${adjStartIndex}" data-current-page="${adjPage}" style="text-align:center">
					<img id="search-indicator" src="${urls.images}/indicatorWhite.gif" style="display:none" />
				</li>
			</#if>
			<script>
				console.log("INITIAL START INDEX = " + "${adjStartIndex}");
				console.log("INITIAL PAGE ADJ = " + "${adjPage}");
			</script>
    </ul>
	</#if>
  </div>  
</div>
</div> <!-- end contentsBrowseGroup -->
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
