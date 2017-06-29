<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<#import "lib-properties.ftl" as p>

<#-- Display of an individual in a list (on /individuallist and menu pages). -->
<#assign hasSubOrgs = false />
<#if parentOrgs?has_content && parentOrgs[0].label != "Cornell University">
	<#assign parent >
	  <#if (parentOrgs?size == 1) >
		<div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
			<div class="col-md-1" style="font-size:14px;color:#CC6949;padding:0;line-height:1.25em;margin-right:8px;">
					College
			</div>
			<div class="col-md-10" style="font-size:14px;padding:0;line-height:1.25em;">
					<a href="${profileUrl(parentOrgs[0].college!)}">${parentOrgs[0].label!}</a>
			</div>
		</div>
	  <#else>
		  <#assign count = 0 />
		  <#list parentOrgs as org >
			<div class="row fff-bkg parent-org" style="margin:0;padding:8px 0 0;">
			<div class="col-md-1" style="font-size:14px;color:#CC6949;padding:0;line-height:1.25em;margin-right:12px;">
					<#if count == 0 >Colleges</#if>
					<#assign count = 1 />
			</div>
			<div class="col-md-10" style="font-size:14px;padding:0;line-height:1.25em;">
					<a href="${profileUrl(org.college!)}">${org.label!}</a>
			</div>
			</div>
	  	  </#list>
	  </#if>
	</#assign>
</#if>
<#if subOrgs?has_content>
	<#assign hasSubOrgs = true />
	<#assign children >
		</div>	
		  <#assign count = 0 />
		  <#list subOrgs as sub >
			<div class="row fff-bkg parent-org" style="margin:0;padding:8px 0 0;display:none" data-org="${subOrgs[0].indLabel!}">
			<div class="col-md-2" style="font-size:14px;color:#CC6949;padding:0;line-height:1.25em;">
					<#if count == 0 ><#if sub.indLabel?contains("Business")>Schools<#else>Departments</#if></#if>
					<#assign count = 1 />
			</div>
			<div class="col-md-10" style="font-size:14px;padding:0;line-height:1.25em;">
					<a href="${profileUrl(sub.dept!)}">${sub.label!}</a>
			</div>
			</div>
		  </#list>
	</#assign>
</#if>
<li class="individual" role="listitem" role="navigation">
    <div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-12" style="padding:0">
			<h1 class="thumb" style="font-size:16px;margin-top:6px;line-height:1.25em;">
				<a href="${individual.profileUrl}" title="visit the ${individual.name} profile page">${individual.name}</a>
				<span class="mst-display" style="font-size: 14px;display: inline;border-left:1px solid #9c9c9c;padding-left:10px">
					${individual.mostSpecificTypes[0]}
				</span>
				<#if hasSubOrgs >
						<#assign linkTitle = "departments" />
						<#if subOrgs[0].indLabel?contains("Business")>
							<#assign linkTitle = "schools" />
						</#if>
						<a class="toggle-children" href="javascript:" title="Display the ${subOrgs[0].indLabel!}'s ${linkTitle!}" style="padding:0;font-size:18px" data-org="${subOrgs[0].indLabel!}" data-state="hidden">
							<i class="fa fa-caret-down" aria-hidden="true"></i>
						</a>
				</#if>
			</h1>
		</div>
	<#if hasSubOrgs >
		${children!}
	<#else>
		</div>
	</#if>
	${parent!}
</li>