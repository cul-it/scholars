<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#setting date_format="yyyy"> 
<#setting locale="en_US">

<#if articleDetails?has_content>
<#assign doi = articleDetails[0].doi! />
<#assign pmid = articleDetails[0].pmid! />
<#assign label = articleDetails[0].label! />
<#assign vol = articleDetails[0].vol! />
<#assign start = articleDetails[0].start! />
<#assign end = articleDetails[0].end! />
<#assign year = articleDetails[0].year! />
<#assign pubYear = year[0..3]?date('yyyy') />
<#assign journal = articleDetails[0].journal!articleDetails[0].freeTextTitle! /> 
</#if>
<#if articleAuthors?has_content>
	<#assign authorCount = articleAuthors?size />
	<#assign authorList>
			<#list articleAuthors as auth >
				<span class="hzntl-author-list" style="display:inline;font-size:16px;">
				<#if auth.type =="vcard">
					<#if auth.name?replace(" ","")?length == auth.name?replace(" ","")?last_index_of(",") + 1 >
						${auth.name?replace(",","")}
					<#else>
						${auth.name}<#if auth_has_next>,</span>
     					<#else></span></#if>
					</#if>
				<#else>
					<#if auth_has_next>
						<#assign authorname = auth.name + ",</a>" />
					<#else>
						<#assign authorname = auth.name + "</a>" />
					</#if>
					<a href="${profileUrl(auth.author)}">${authorname!}</span>
				</#if>
			</#list>
	</#assign>
</#if>
<#assign altmetric = "" />
	<#-- if altmetricEnabled?? -->
	    <#if doi?has_content>
	 		<#assign altmetric >
	            <div class="individual-altmetric-badge-inline">
	                <div class="altmetric-embed"
	                     data-badge-type="4"
	                     data-badge-popover="left"
	                     data-badge-details=""
	                     data-hide-no-mentions="true"
	                     data-link-target="_blank"
	                     data-doi="${doi!}">
	                </div>
	            </div>
			</#assign>
	    <#elseif pmid?has_content>
 			<#assign altmetric >
		           <div class="individual-altmetric-badge">
		               <div class="altmetric-embed"
		                    data-badge-type="4"
		                    data-badge-popover="left"
		                    data-badge-details=""
		                    data-hide-no-mentions="true"
		                    data-link-target="_blank"
		                    data-doi="${pmid!}">
		               </div>
		           </div>
			</#assign>
	    </#if>
<li class="individual" role="listitem" role="navigation">
    <div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-1" style="padding-left:0;font-size: 20px;margin-top: 3px;"><img height="24px" src="${urls.theme}/images/pubs-icon.png"></i>
		</div>
		<div class="col-md-<#if !altmetric?has_content>11<#else>9</#if>" style="padding:0">
	    	<h1 class="thumb" style="font-size:16px;margin-top:6px;line-height:1.25em">
	        	<a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}.</a> 
	    	</h1>
		</div>
		<#if altmetric?has_content >
			<div class="col-md-2" style="font-size:16px;padding:0">
				${altmetric!}
			</div>
		</#if>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-2" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
				Author<#if (authorCount > 1)>s</#if>
		</div>
		<div class="col-md-10" style="font-size:16px;padding:0;line-height:1.25em">
				${authorList!}
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-2" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
			Journal
		</div>
		<div class="col-md-10" style="font-size:16px;padding:0;line-height:1.25em">
			<em>${journal!}</em>.
		</div>
	</div>
    <div class="row fff-bkg" style="margin:0;padding:8px 0 0;">
		<div class="col-md-2" style="font-size:16px;color:#CC6949;padding:0;line-height:1.25em">
			Published
		</div>
		<div class="col-md-10" style="font-size:16px;padding:0;line-height:1.25em">
			${pubYear!}
		</div>
	</div>
</li>


