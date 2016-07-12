<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Icon controls displayed in upper-right corner -->
<#-- CU directory link -->
<img id="uriIcon" title="Share the URI or view this profile's RDF" data="${individual.uri}" width="32px" src="${urls.base}/themes/scholars/images/share-uri-icon.png" alt="share the uri" style="margin-left:6px"/>
<#if fullTextLink?? && fullTextLink?has_content >
	<a href="${fullTextLink!}" title="View the departmental page" target="_blank">
		<img id="fullTextIcon" title="View the full text of this document" width="32px" src="${urls.base}/themes/scholars/images/full-text-icon.png" alt="view the full text" style="margin-left:6px"/>
	</a>
</#if>
