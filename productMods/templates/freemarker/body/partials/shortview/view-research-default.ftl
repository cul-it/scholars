<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#setting date_format="yyyy"> 
<#setting locale="en_US">

<#if grantContractDetails?has_content>
<#assign adminOrg = grantContractDetails[0].adminOrg! />
<#assign orgLabel = grantContractDetails[0].orgLabel! />
<#assign funder = grantContractDetails[0].funder! />
<#assign start = grantContractDetails[0].start! />
<#assign end = grantContractDetails[0].end! />
<#assign sYear = start[0..3]?date('yyyy') />
<#assign eYear =end[0..3]?date('yyyy') />
</#if>
<li class="individual" role="listitem" role="navigation">
    <div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-11" style="padding:0">
	    	<h1 class="thumb" style="font-size:16px;margin-top:6px;line-height:1.25em;">
	        	<a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
	    	</h1>
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Academic unit
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				${orgLabel!}
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Funding Agency
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				${funder!}
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
			Years active
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				${sYear!}<#if eYear?has_content> - ${eYear!}</#if>
		</div>
	</div>
</li>
