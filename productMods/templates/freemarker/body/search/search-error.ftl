<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying search error message -->
<div class="row scholars-row">
	<div id="container" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
	<#if title??>
		<h2 class="expertsResultsHeader">${title?html}</h2>
	</#if>
		<div style="margin-left:30px">	
			<p>
				${message?html}
			</p>
			<#include "search-help.ftl" >
		</div>
	</div>
</div>