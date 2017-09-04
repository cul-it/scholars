<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for faux property "people". See the PropertyConfig.3 file for details.
    
     This template must be self-contained and not rely on other variables set for the individual page, because it
     is also used to generate the property statement during a deletion.  
 -->
<#import "lib-sequence.ftl" as s>

<@showAffiliations statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showAffiliations statement>
    <#local linkedIndividual>

        <#if statement.person??>
            <a href="${profileUrl(statement.uri("person"))}" title="${i18n().person_name}">${statement.personLabel!}</a>
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            <a href="${profileUrl(statement.uri("affn"))}" title="person missing from affiliation">person missing from affiliation</a>
        </#if>
    </#local>

    <@s.join [ linkedIndividual, statement.posnLabel! ] />
</#macro>
