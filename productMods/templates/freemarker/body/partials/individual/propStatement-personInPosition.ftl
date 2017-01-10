<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "positions". See the PropertyConfig.3 file for details. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#import "lib-sequence.ftl" as s>
<#import "lib-datetime.ftl" as dt>

<@showPosition statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showPosition statement>
	<#if statement.posnInUnit?? && (statement.posnInUnitName != statement.orgName!) >
		<#assign validPosInUnit = true />
	<#else>
		<#assign validPosInUnit = false />
	</#if>	
    <#local posTitle>
        <span itemprop="jobTitle">${statement.positionTitle!statement.hrJobTitle!}<#if statement.org??>,</#if></span>
    </#local>
    <#local parentOrganization>
        <#if statement.org??>
            <span itemprop="worksFor" itemscope itemtype="http://schema.org/Organization">
               <a itemprop="name" href="${profileUrl(statement.uri("org"))}" title="${i18n().organization_name}">${statement.orgName}</a>
            </span>
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            <a href="${profileUrl(statement.uri("position"))}" title="${i18n().missing_organization}">${i18n().missing_organization}</a>
        </#if>
    </#local>
    <#local positionInUnit>
		<#if validPosInUnit >
        	<span itemprop="worksFor" itemscope itemtype="http://schema.org/Organization">
            	<a itemprop="name" href="${profileUrl(statement.uri("posnInUnit"))}" title="${i18n().middle_organization}">${statement.posnInUnitName!}</a><#if statement.org??>,</#if>
        	</span>
		</#if>
    </#local>
    
    ${posTitle!} ${positionInUnit!} ${parentOrganization}   <@dt.yearIntervalSpan "${statement.dateTimeStart!}" "${statement.dateTimeEnd!}" />
</#macro>
