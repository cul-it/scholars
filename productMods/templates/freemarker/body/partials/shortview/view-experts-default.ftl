<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#import "lib-properties.ftl" as p>

<#assign pubDetails>
<#if pubCount?has_content && (pubCount[0].lcount?number > 0) >
	<div id="pub-details">
    	<span class="title">
			${pubCount[0].lcount} publication<#if (pubCount[0].lcount?number > 1) >s in ${pubCount[0].jcount} journal<#if (pubCount[0].jcount?number > 1) >s</#if></#if> 
		</span>
	</div>
</#if>
</#assign>
<#assign posnInfo >
<#if position?has_content>
	<#list position as posn >
        <span class="title">${posn.expPosn}, ${posn.orgLabel}</span>
	</#list>
</#if>
</#assign>
<#assign jCount = pubCount[0].jcount?number />

<li class="individual" role="listitem" role="navigation">
  

<#if (individual.thumbUrl)??>
    <div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-7" style="padding:0">
			<img src="${individual.thumbUrl}" width="80" alt="${individual.name}" />
		</div>
		<div class="col-md-5" style="padding:0">
			${pubDetails!}
		</div>
		<div class="col-md-9" style="padding:0">
	    	<h1 class="thumb" style="font-size:16px">
	        	<a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
	    	</h1>
		</div>
	</div>
	<div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-12" style="padding:0;margin-top:-10px">
			${posnInfo}
		</div>
	</div>
<#else>
    <div class="row fff-bkg" style="margin:0;padding:0;">
		<div class="col-md-7" style="padding:0">
	    	<h1 class="thumb" style="font-size:16px;margin-top:14px">
	        	<a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
	    	</h1>
		</div>
		<div class="col-md-5" style="padding:0">
			${pubDetails!}
		</div>
		<div class="col-md-12"  style="padding:0;margin-top:-10px" >
			${posnInfo}
		</div>
	</div>
</#if>
</li>


