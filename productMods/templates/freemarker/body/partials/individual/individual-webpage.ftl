<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- 
    This snippet will be included in lib-vivo-properties.ftl, so users will be able to have a 
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
<script>
    <#if individual.organization() >
        <#-- 
               Academic Departments have a "view active grants link" and the css is geared to this. For other orgs,
               adjust the margins to get the correct layout.
        -->
        if (!$('div#activeGrantsLink').length > 0) {
            $('ul.webpages-withThumbnails li:nth-child(2)').find('img.org-webThumbnail').css('margin-top', '49px');
            $('ul.webpages-withThumbnails li:nth-child(2)').find('a.weblink-icon').css('margin-top', '109px');
        }    

        // the webpage indicator span displays an "in progress" icon until
        // the thumbnail gets loaded. Once loaded, show/hide relevant elements 
        $.each($('span.webpage-indicator'), function() {
            var identifier = $(this).attr('id');
            identifier = identifier.replace('span-','');
            $('img#img-' + identifier).load(function(){
                $('span#span-' + identifier).hide();
                $('div#' + identifier).fadeIn();
            });
        });

    </#if>
</script>
    

