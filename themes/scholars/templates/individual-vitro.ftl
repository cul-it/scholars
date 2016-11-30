<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->
<#import "lib-microformats.ftl" as mf>
<#assign verbose = (verbosePropertySwitch.currentValue)!false>
<#--Number of labels present-->
<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>
<#--Number of available locales-->
<#if !localesCount??>
	<#assign localesCount = 1>
</#if>
<#--Number of distinct languages represented, with no language tag counting as a language, across labels-->
<#if !languageCount??>
	<#assign languageCount = 1>
</#if>	

<#-- Default individual profile page template -->
<#assign subjectUri = individual.controlPanelUrl()?split("=") >
<div id="row1" class="row scholars-row">
<div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="generic-main-column">
    <section id="share-contact" role="region">
        <#-- Image -->
        <#assign individualImage>
        <@p.image individual=individual
            propertyGroups=propertyGroups
            namespaces=namespaces
            editable=editable
            showPlaceholder="with_add_link" />
        </#assign>

        <#if ( individualImage?contains('<img class="individual-photo"') )>
            <#assign infoClass = 'class="withThumb"'/>
        </#if>
        <div id="photo-wrapper">${individualImage}</div>
    </section>
    <!-- start section individual-info -->
    <section id="individual-info" ${infoClass!} role="region">
        <#include "individual-adminPanel.ftl">

        <#if individualProductExtensionPreHeader??>
            ${individualProductExtensionPreHeader}
        </#if>

        <header>
            <#if relatedSubject??>
                <h2>${relatedSubject.relatingPredicateDomainPublic} for ${relatedSubject.name}</h2>
                <p><a href="${relatedSubject.url}" title="${i18n().return_to(relatedSubject.name)}">&larr; ${i18n().return_to(relatedSubject.name)}</a></p>                
            <#else>                
                <h1 class="fn generic-page-header" itemprop="name"">
                    <#-- Label -->
                    <@p.label individual editable labelCount localesCount languageCount/>

                    <#--  Most-specific types -->
                    <@p.mostSpecificTypes individual />
                    <span id="iconControlsVitro"><img id="uriIcon" title="${individual.uri}" class="middle" src="${urls.images}/individual/uriIcon.gif" alt="uri icon"/></span>
                </h1>
            </#if>
			<h2 id="generic-page-heading-break">  </h2>
        </header>
                
            </section> <!-- individual-info -->
	</div> <!-- generic-main-column -->
</div> <!-- row1 -->

<div id="row2" class="row scholars-row foaf-organization-row2">
  <div id="foafOrgTabs" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
	<div id="scholars-tabs-container">
		<#assign count = 1 />
  		<ul id="scholars-tabs">
  			<#list individual.propertyList.all as group>
  		    	<li><a href="#tabs-${count}"><#if group.name?has_content>${group.name?capitalize}<#else>Other</#if></a></li>
  				<#assign count = count+1 />
  			</#list>
  		</ul>
  		<#assign count = 1 />
		<#list individual.propertyList.all as group>
	  		<div id="tabs-${count}"  class="tab-content">
	  			<article class="scholars-property" role="article">
	  			    <ul id="individual-faculty" class="property-list" role="list">
						<li>
							<#include "individual-properties.ftl">
						</li>
	  				</ul>
	  			</article>	
	  		</div>
  			<#assign count = count+1 />
  		</#list>
  	</div>
  </div>
</div> <!-- row2 -->
<#assign rdfUrl = individual.rdfUrl>

<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>
<script>
    var i18nStringsUriRdf = {
        shareProfileUri: '${i18n().share_profile_uri}',
        viewRDFProfile: '${i18n().view_profile_in_rdf}',
        closeString: '${i18n().close}'
    };
	var i18nStrings = {
	    displayLess: '${i18n().display_less}',
	    displayMoreEllipsis: '${i18n().display_more_ellipsis}',
	    showMoreContent: '${i18n().show_more_content}',
	};

</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-1.0.0-rc3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualUriRdf.js"></script>')}

<script type="text/javascript">
    i18n_confirmDelete = "${i18n().confirm_delete}"
</script>

<script>
	$(function() {
	  $( "#scholars-tabs-container" ).tabs();
	});
</script>
<#-- @dumpAll/ -->
