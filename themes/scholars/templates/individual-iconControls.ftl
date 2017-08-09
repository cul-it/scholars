<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Icon controls displayed in upper-right corner -->
<#-- CU directory link -->
<#if individual.person() >
<#assign netidProp = propertyGroups.pullProperty("http://scholars.cornell.edu/ontology/hr.owl#netId")>
<#assign netId = netidProp.statements?first />
<#if netId?has_content>
    <a href="http://www.cornell.edu/search/?tab=people&netid=${netId.value}" title="View the departmental page" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Icons', 'Person', 'CornellSearch-Icon']);">
    	<img src="${urls.base}/themes/scholars/images/contact-info-icon.png" width="32px" title="Click to view contact information" alt="contact info" />
    </a>
</#if>
<img id="uriIcon" title="Share the URI or view this profile's RDF" data="${individual.uri}" width="32px" src="${urls.base}/themes/scholars/images/share-uri-icon.png" alt="share the uri" class="icon-control"/>
<#if orcidID?has_content>
	<a href="${theOrcidId!}" title="View the ORCID page" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Icons', 'Person', 'ORCID-Icon']);">
		<img id="orcidIcon" title="View ORCiD page" width="32px" src="${urls.base}/themes/scholars/images/orcid-icon.png" alt="Click to view ORCiD page" class="icon-control"/>
	</a>
</#if>
<#if webpageUrl?has_content>
	<a href="${webpageUrl!}" title="View the departmental page" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Icons', 'Person', 'PersonalWebsite-Icon']);">
		<img id="webIcon" title="Click to view websites" width="32px" src="${urls.base}/themes/scholars/images/websites-icon.png" alt="Click to view website/s" class="icon-control"/>
	</a>
</#if>
</#if>
<#if individual.organization() >
	<#if webpageUrl?has_content>
		<#if isAcademicDept>
			<#assign theType = "deparmental" />
		<#elseif isCollegeOrSchool >
			<#assign theType = "college or school" />
		</#if>
		<a href="${webpageUrl!}" title="View the departmental page" target="_blank" onclick="javascript:_paq.push(['trackEvent', 'Icons', 'Department-School-College', 'Webpage-Icon']);">
			<img src="${urls.base}/themes/scholars/images/contact-info-icon.png" width="32px" title="Click to view the ${theType!} webpage" alt="contact info" />
		</a>
	</#if>
	<img id="uriIcon" title="Share the URI or view this profile's RDF" data="${individual.uri}" width="32px" src="${urls.base}/themes/scholars/images/share-uri-icon.png" alt="share the uri" class="icon-control"/>
</#if>