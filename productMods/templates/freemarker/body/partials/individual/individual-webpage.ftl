<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- This snippet will be included in lib-vivo-properties.ftl, so users will be able to have a 
    different view when extending wilma theme

    <#assign webpage = propertyGroups.pullProperty("${core}webpage")!>
    <@p.objectPropertyListing webpage editable />
    
    
-->
    <#assign webpage = propertyGroups.pullProperty("${core}webpage")!>
    <#if webpage?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
        <@p.addLinkWithLabel webpage editable "Websites"/>
        <#assign localName = webpage.localName>
        <ul id="individual-${localName}" class="<#if individual.organization()>webpages-withThumbnails<#else>individual-urls</#if>" role="list" <#if individual.organization() && !editable>style="margin-top:20px"</#if>>
            <@p.objectProperty webpage editable />
        </ul>
    </#if>

