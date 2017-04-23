<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default individual browse view -->

<#import "lib-properties.ftl" as p>

<li class="individual" role="listitem" role="navigation">

<#if (individual.thumbUrl)??>
    <img src="${individual.thumbUrl}" width="90" alt="${individual.name}" />
    <h1 class="thumb">
        <a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
    </h1>
<#else>
    <h1>
        <a href="${individual.profileUrl}" title="View the profile page for ${individual.name}}">${individual.name}</a>
    </h1>
</#if>

<#if position?has_content>
        <span class="title">${position[0].expPosn}, ${position[0].orgLabel}</span><br/>
</#if>
<#if pubCount?has_content>
        <span class="title">${pubCount[0].lcount}, ${pubCount[0].jcount}</span><br/>
</#if>
</li>
