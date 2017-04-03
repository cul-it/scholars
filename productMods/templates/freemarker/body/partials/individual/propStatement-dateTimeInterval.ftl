<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for http://vivoweb.org/ontology/core#dateTimeInterval. 
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->

<#import "lib-datetime.ftl" as dt>
<#--
     Added ! statement.label?? to this if statement. Otherwise, we display the incomplete message
     even when there is a valid label (possibly via ingest), such as Spring 2010.  tlw72
-->

<#if ! statement.valueStart?? && ! statement.valueEnd?? && ! statement.label?? >
    <a href="${profileUrl(statement.uri("dateTimeInterval"))}" title="${i18n().incomplete_date_time_interval}">${i18n().incomplete_date_time_interval}</a>
<#else>
    <#if statement.label??>
        ${statement.label!}
    <#else>
		<#if statement.dateTimeStart?? && statement.dateTimeStart?contains("Z")>

			<#setting time_zone='GMT'>
			<#setting datetime_format='YYYY-MM-DD HH:MM:SS'>

			${statement.dateTimeStart[0..9]?date('yyyy-MM-dd')?string.long}
			
			<#if statement.dateTimeEnd?? >
				-	${statement.dateTimeEnd[0..9]?date('yyyy-MM-dd')?string.long}
			</#if>
		<#else>    
			${dt.dateTimeInterval("${statement.dateTimeStart!}", "${statement.precisionStart!}", "${statement.dateTimeEnd!}", "${statement.precisionEnd!}")} 
		</#if>
    </#if>
</#if>
