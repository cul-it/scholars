<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- The "quick view" individual profile page template for foaf:Person individuals -->
<!--[if IE 7]>
<link rel="stylesheet" href="${urls.theme}/css/ie7-quick-view.css" />
<![endif]-->

<#-- <#include "individual-setup.ftl"> -->
<#import "individual-qrCodeGenerator.ftl" as qr>
<#import "lib-vivo-properties.ftl" as vp>

<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>

<#assign individualImage>
    <@p.image individual=individual 
              propertyGroups=propertyGroups 
              namespaces=namespaces 
              editable=editable 
              showPlaceholder="always"/>
</#assign>

<#-- 
     the display in this template is driven by whether the individual has a web page,
     so set this variable now
-->
<#assign hasWebpage = false>
<#assign web = individual.propertyList.getProperty("${core}webpage")!>
<#if editable >
    <#if web.first()?? >
        <#assign hasWebpage = true>
    <#else>
        <#assign hasWebpage = false>
    </#if>
<#else>
    <#if (web?size > 0) >
        <#assign hasWebpage = true>
    <#else>
        <#assign hasWebpage = false>
    </#if>
</#if>

<section id="individual-intro" class="vcard person" role="region">
    <section id="label-title" <#if editable>style="width:45%"</#if> >
        <header>
            <#if relatedSubject??>
                <h2>${relatedSubject.relatingPredicateDomainPublic} for ${relatedSubject.name}</h2>
                <p><a href="${relatedSubject.url}" title="return to">&larr; return to ${relatedSubject.name}</a></p>
            <#else> 
                <#-- Image  -->
                <div id="photo-wrapper" >${individualImage}</div>
                <h1 class="vcard foaf-person fn" <#if !editable>style="float:left;border-right:1px solid #A6B1B0;"</#if>> 
                    <#-- Label -->
                    <@p.label individual editable labelCount/>
                </h1>
                <#--  Display preferredTitle if it exists; otherwise mostSpecificTypes -->
                <#assign title = propertyGroups.pullProperty("${core}preferredTitle")!>
                <#if title?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
                    <@p.addLinkWithLabel title editable />
                    <#list title.statements as statement>
                        <#if !editable >
                            <div id="titleContainer"><span class="display-title-not-editable">${statement.value}</span></div>
                        <#else>
                            <span class="display-title-editable">${statement.value}</span>
                            <@p.editingLinks "${title.name}" statement editable />
                        </#if>
                    </#list>
                </#if>
                <#-- If preferredTitle is unpopulated, display mostSpecificTypes -->
                <#if ! (title.statements)?has_content>
                    <@p.mostSpecificTypesPerson individual editable /> 
                </#if>
            </#if>       
        </header>
    </section> <!-- end label-title  -->
    <#include "individual-adminPanel.ftl">

    <span class="<#if editable >iconControlsEditable<#else>iconControlsNotEditable</#if>">
        <#include "individual-iconControls.ftl">
    </span>
    <#if editable >
        <div id="profileTypeContainer" <#if editable>style="margin-top:22px"</#if>>
            <h2>Profile type</h2>
            <select id="profilePageType">
                <option value="standard" <#if profileType == "standard" || profileType == "none">selected</#if> >Standard profile view</option>
                <option value="quickView" <#if profileType == "quickView">selected</#if> >Quick profile view</option>
            </select>
        </div>
    </#if>

    <#-- 
        If this individual has a web page or pages, then we highlight them on the left-hand side
        of the profile page against a shaded background. If not, all the right-hand content shifts
        left and displays across the full width of the page.
    -->
    <#if hasWebpage >
        <section id="qv-share-contact" class="share-contact" role="region" <#if !editable>style="padding-top:12px"</#if>> 
            <img id="webpage-popout-top" src="${urls.images}/individual/webpage-popout-top.png"  alt="background top"/>
            <div id="webpage-wrapper" >
                <#assign webpage = propertyGroups.pullProperty("${core}webpage")!>            
                <#if webpage?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
                    <#if editable>
                        <h2 class="websites" >Websites <@p.addLink webpage editable ""/></h2>
                    </#if>
                    <@p.verboseDisplay webpage />
                    <#assign localName = webpage.localName>
                    <ul id="individual-${localName}" class="individual-webpage" role="list">
                        <@p.objectProperty webpage editable "propStatement-webpage-quickview.ftl"/>
                    </ul>
                </#if>
            </div>
            <img id="webpage-popout-bottom" src="${urls.images}/individual/webpage-popout-bottom.png"  alt="background top"  <#if editable>style="margin-top:16px"</#if>/>
        </section> <!-- end share-contact -->
    </#if>
    <section id="individual-info" class="qv-individual-info" role="region" style=" <#if !editable>padding-top:12px;</#if><#if hasWebpage>width:53%<#else>width:100%;clear:left</#if>;">       
        <!-- Positions -->
        <#include "individual-positions.ftl">

        <!-- Research Areas -->
        <#include "individual-researchAreas.ftl">

        <!-- Geographic Focus -->
        <#assign geographicFocus = propertyGroups.pullProperty("${core}geographicFocus")!> 
        <#if geographicFocus?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
            <h2 id="webpage" class="mainPropGroup">Geographic Focus <@p.addLink geographicFocus editable ""/></h2>
            <@p.verboseDisplay geographicFocus />
            <#assign localName = geographicFocus.localName>

            <#assign subclasses = geographicFocus.subclasses>
            <#list subclasses as subclass>
                <#assign subclassName = subclass.name!>
                <ul id="individual-${localName}" role="list">
                    <@p.objectPropertyList geographicFocus editable subclass.statements geographicFocus.template/>
                </ul>
            </#list>
        </#if>   

        <#-- If the individual does not have webpages and we're in edit mode, provide the opportunity to add webpages -->
        <#if editable && !hasWebpage >
            <!-- Webpages -->
            <#assign webpage = propertyGroups.pullProperty("${core}webpage")!>            
            <#if webpage?has_content>
                <h2 id="webpage" class="mainPropGroup">Websites <@p.addLink webpage editable ""/></h2>
                <@p.verboseDisplay webpage />
                <#assign localName = webpage.localName>
                <ul id="individual-${localName}" role="list">
                    <@p.objectProperty webpage editable />
                </ul>
            </#if>
        </#if>
        <#include "individual-visualizationQuickView.ftl">

		<#include "individual-openSocial.ftl">
    </section> <!-- end individual-info -->
</section> <!-- end end individual-intro -->
<!-- we need these 3 lines of html to provide proper spacing and alignment -->
<p style="clear:both">
    <br />
</p>
<span id="fullViewLink">
    <a href="${urls.base}/display/${individual.localName}?destination=standardView" >
        <img id="fullViewIcon" src="${urls.images}/individual/fullViewIcon.png" alt="full view icon"/>
    </a>
</span>
<#if !editable>
<script>
    var title = $('div#titleContainer').width();
    var name = $('h1.vcard').width();
    var total = title + name;
    if ( name < 400 && total > 730 ) {
        var diff = total - 730;
        $('div#titleContainer').width(title - diff);
    }
    else if ( name > 399 && name + title > 730 ) {
        $('div#titleContainer').width('800');
    }
</script>
</#if>
<script>
    var individualLocalName = "${individual.localName}";
    var imagesPath = '${urls.images}';
</script>
<#assign rdfUrl = individual.rdfUrl>

<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>
<script type="text/javascript">
var profileTypeData = {
    processingUrl: '${urls.base}/edit/primitiveRdfEdit',
    individualUri: '${individual.uri!}',
    defaultProfileType: '${profileType!}'
};
</script>
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-quick-view.css" />',
                  '<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.8.9.custom.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/amplify/amplify.store.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUriRdf.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualQtipBubble.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.8.9.custom.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualProfilePageType.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>')}
