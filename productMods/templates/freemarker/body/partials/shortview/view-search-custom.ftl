<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual search view -->

<#import "lib-properties.ftl" as p>

<a href="${individual.profileUrl}" title="individual name">${individual.name}</a>

<#if individual.preferredTitle?has_content>
    <span class="display-title">${individual.preferredTitle}</span>
<#elseif position?has_content>
    <span class="display-title">${position[0].posLabel}, ${position[0].orgLabel}</span>
<#else>
    <@p.mostSpecificTypes individual />
</#if>

<p class="snippet">${individual.snippet}</p>
