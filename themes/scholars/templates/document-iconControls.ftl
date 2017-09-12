<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Icon controls displayed in upper-right corner -->
<#-- CU directory link -->
<#if fullTextLink?? && fullTextLink?has_content >
	<a  href="${fullTextLink!}" title="View the full text" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Icons', 'Document', 'FullText-Icon']);">
		<i class="fa fa-file-text" aria-hidden="true"></i>Full Text</a>
</#if>

<#--
<img id="uriIcon" class="doc-controls-img" title="Share the URI or view this profile's RDF" data="${individual.uri}" width="32px" src="${urls.base}/themes/scholars/images/share-uri-icon.png" alt="share the uri"/>



		<img id="fullTextIcon" class="doc-controls-img" title="View the full text of this document" width="32px" src="${urls.base}/themes/scholars/images/full-text-icon.png" alt="view the full text"/>
		
-->