<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#--  Add web page thumbnail when an individual foaf:organization has core:webpage content -->
<#if individual?? && individual.organization> 
    <ul class="${linkListClass}" id="webpages-withThumbnails" role="list">
        <@p.objectPropertyList webpage editable />
    </ul>
<#else>
    <ul class="${linkListClass}" id="webpages" role="list">
        <@p.objectPropertyList webpage editable />
    </ul>
</#if>
