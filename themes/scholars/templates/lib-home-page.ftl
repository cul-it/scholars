<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Macros used to build the statistical information on the home page -->

<#-- Get the classgroups so they can be used to qualify searches -->
<#macro allClassGroupNames classGroups>
    <#list classGroups as group>
        <#-- Only display populated class groups -->
        <#if (group.individualCount > 0)>
            <li role="listitem"><a href="" title="${group.uri}">${group.displayName?capitalize}</a></li>
        </#if>
    </#list>
</#macro>
<#-- We need the faculty count in order to randomly select 4 faculty using a search query -->
<#macro facultyMemberCount classGroups>
    <#assign foundClassGroup = false />
    <#list classGroups as group>
        <#if (group.individualCount > 0) && group.uri?contains("people") >
            <#list group.classes as class>
                <#if (class.uri?contains("FacultyMember")) >
                    <#assign foundClassGroup = true />
                    <#if (class.individualCount > 0) >
                        <script>var facultyMemberCount = ${class.individualCount?string?replace(",","")?replace(".","")};</script>
                    <#else>
                        <script>var facultyMemberCount = 0;</script>
                    </#if>
                </#if>
            </#list>
        </#if>
     </#list>
     <#if !foundClassGroup>
        <script>var facultyMemberCount = 0;</script>
    </#if>
</#macro>

<#-- renders the "geographic focus" section on the home page. works in      -->
<#-- conjunction with the homePageMaps.js and latLongJson.js files, as well -->
<#-- as the leaflet javascript library.                                     -->
<#macro downloadCounts>
	<#if facultyCount?has_content>
        <#assign researchersCount = facultyCount[0].count?number + professionalCount[0].count?number />
		<div id="download-content" class="row fff-bkg">
				<div class="col-sm-1 col-md-1 col-lg-1"></div>
				<div class="col-sm-3 col-md-3 col-lg-3">
					<a class="researcher-link" href="/scholars/people"><div id="researcher-count"><p>${researchersCount}</p></div></a>
					<a class="researcher-link" href="/scholars/people"><div id="researcher-text"><p>Researchers</p></div></a>
				</div>
				<div class="col-sm-3 col-md-3 col-lg-3">
					<a class="grant-link" href="/scholars/research#http://vivoweb.org/ontology/core#Grant"><div id="grant-count" ><p>${grantCount[0].count?number}</p></div></a>
					<a class="grant-link" href="/scholars/research#http://vivoweb.org/ontology/core#Grant"><div id="grant-text"><p>Grants</p></div></a>
				</div>
				<div class="col-sm-3 col-md-3 col-lg-3">
					<a class="article-link" href="/scholars/research#http://purl.org/ontology/bibo/AcademicArticle "><div id="article-count" ><p >${articleCount[0].count?number}</p></div></a>
					<a class="article-link" href="/scholars/research#http://purl.org/ontology/bibo/AcademicArticle "><div id="article-text"><p>Articles</p></div></a>
				</div>
				<div class="col-sm-2 col-md-2 col-lg-2">
					<a class="journal-link" href="/scholars/research#http://purl.org/ontology/bibo/Journal "><div id="journal-count" ><p>${journalCount[0].count?number}</p></div></a>
					<a class="journal-link" href="/scholars/research#http://purl.org/ontology/bibo/Journal "><div id="journal-text"><p>Journals</p></div></a>
				</div>
		</div>
	</#if>
</#macro>
