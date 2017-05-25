<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for the main Site Administration page -->

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/admin.css" />')}

<div class="row scholars-row">
	<div class="col-md-12 scholars-container">
		<h2 class="expertsResultsHeader">Site Administration</h2>
		<div id="adminDashboard">
    		<#include "siteAdmin-dataInput.ftl">
    		<#include "siteAdmin-siteConfiguration.ftl">
    		<#include "siteAdmin-ontologyEditor.ftl">
    		<#include "siteAdmin-advancedDataTools.ftl">
    		<#include "siteAdmin-siteMaintenance.ftl">
		</div>
	</div>
</div>

