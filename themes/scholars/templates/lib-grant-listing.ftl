<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-----------------------------------------------------------------------------
    Macros for listing grants
------------------------------------------------------------------------------>

<#import "lib-datetime.ftl" as dt>
<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro listGrants property>
	<#assign hasActiveHeading = false /> 
	<#assign hasConcludedHeading = false /> 
	<#assign template = property.template />
	<#list property.statements as statement>
		<#assign currentYear = .now?string.yyyy?number />
		<#assign grantEndYear = statement.dateTimeEndGrant[0..3]?number />
		<#if (grantEndYear >= currentYear) && !hasActiveHeading >
			<h4 class="grantStatusHeading">- active -</h4>
			<#assign hasActiveHeading = true /> 
		</#if>
		<#if (grantEndYear < currentYear) && !hasConcludedHeading >
			<h4 class="grantStatusHeading">- concluded -</h4>
			<#assign hasConcludedHeading = true /> 
		</#if>
		<li role="listitem"> 
			<#include "${template}">
		</li>
	</#list>
</#macro>
