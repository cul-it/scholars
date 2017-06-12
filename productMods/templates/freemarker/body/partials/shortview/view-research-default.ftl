<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#setting date_format="yyyy"> 
<#setting locale="en_US">

<#if grantContractDetails?has_content>
<#assign adminOrg = grantContractDetails[0].adminOrg!"" />
<#assign orgLabel = grantContractDetails[0].orgLabel!"" />
<#assign fundingOrg = grantContractDetails[0].fundingOrg!"" />
<#assign funder = grantContractDetails[0].funder!"" />
<#assign start = grantContractDetails[0].start! />
<#assign end = grantContractDetails[0].end! />
<#assign sYear = start[0..3]?date('yyyy') />
<#assign eYear =end[0..3]?date('yyyy') />
</#if>
<#if grantContractInvestigators?has_content>
	<#assign pis = "" />
	<#assign coPis = "" />
	<#list grantContractInvestigators as gci >
		<#if gci.type == "1-PI" >
			<#assign tempPi>
				<span class="hzntl-author-list" style="display:inline;font-size:16px;">
					<a href="${profileUrl(gci.person)!}">${gci.personLabel!}<#if gci_has_next>,</#if></a>
				</span>
			</#assign>
			<#assign pis = pis + tempPi />
		<#elseif gci.type == "2-Co-PI" >
			<#assign tempCoPi>
				<span class="hzntl-author-list" style="display:inline;font-size:16px;">
					<a href="${profileUrl(gci.person)!}">${gci.personLabel!}<#if gci_has_next>,</#if></a>
				</span>
			</#assign>
			<#assign coPis = coPis + tempCoPi />
		</#if>
	</#list>
</#if>
<li class="individual" role="listitem" role="navigation">
    <div class="row fff-bkg" style="margin:0;padding:0;">
	<div class="col-md-1" style="padding-left:0;font-size: 20px;margin-top: 3px;"><i class="fa fa-university" aria-hidden="true"></i>
	</div>
		<div class="col-md-11" style="padding:0">
	    	<h1 class="thumb" style="font-size:16px;margin-top:6px;line-height:1.25em;">
	        	<a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
	    	</h1>
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Principal Inv.
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				${pis!}
		</div>
	</div>
	<#if coPis?has_content>
	    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
			<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
					Co-principle Inv.
			</div>
			<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
					${coPis!}
			</div>
		</div>
	</#if>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Administered By
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				<a href="${profileUrl(adminOrg!)}" title="View the profile page for ${orgLabel!}">${orgLabel!}</a>
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Funding Agency
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
	  <#if funder?? >
		<a href="${profileUrl(fundingOrg!)}" title="View the profile page for funding agency">
		${funder?capitalize?replace("Nsf","NSF")?replace("Nih","NIH")?replace("Dhhs","DHHS")?replace("usda","USDA")?replace("Usda","USDA")?replace("A&m","A&M")?replace("Doe","DOE")?replace("Dod","DOD")?replace("Rsch","RSCH")?replace("Res","RES")?replace("Ltd","LTD")?replace("Fdn","FDN")?replace("Doi","DOI")?replace("Gsa","GSA")?replace("Doc","DOC")?replace(" Us"," US")}</a>
	  </#if>
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-3" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
			Years Active
		</div>
		<div class="col-md-9" style="font-size:16px;padding:0;line-height:1.25em">
				${sYear!}<#if eYear?has_content> - ${eYear!}</#if>
		</div>
	</div>
</li>
