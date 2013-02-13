<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Display of an individual in a list (on /individuallist and menu pages). -->

<#import "lib-vivo-properties.ftl" as p>

<a href="${individual.profileUrl}" title="individual name">${individual.name}</a>

<#if individual.preferredTitle?has_content>
    <span class="display-title">${individual.preferredTitle}</span>
<#elseif position?has_content>
    <span class="display-title">${position[0].posLabel}, ${position[0].orgLabel}</span>
</#if>

<#--
<@p.displayTitle individual />
-->

<#-- add display of web pages? -->