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
<div id="by-the-numbers-backdrop" class="row fff-bkg">
		<div id="researchers-count" class="btn-count-container">
			<p id="researcher-count" class="btn-count">0</p>
				<p class="btn-text">Researchers</p>
		</div>
		<div id="articles-count" class="btn-count-container">
			  <p id="article-count" class="btn-count">0</p>
				<p class="btn-text">Articles</p>
		</div>
		<div id="grants-count" class="btn-count-container">
			  <p id="grant-count" class="btn-count">0</p>
				<p class="btn-text">Grants</p>
		</div>
		<div id="journals-count" class="btn-count-container">
			  <p id="journal-count" class="btn-count">0</p>
				<p class="btn-text"> Journals</p>
		</div>
		<div id="by-the-numbers-text">
	  		<p>Scholars<span>@</span>Cornell &ndash; By the Numbers</p>
		</div>
</div>
</#macro>
