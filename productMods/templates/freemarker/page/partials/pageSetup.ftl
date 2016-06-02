<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- pageSetup.ftl is automatically included for all page template requests.
It provides an avenue to assign variables related to display, which fall outside
the domain of the controllers. -->

<#assign bodyClasses>
    <#-- The compress directives and formatting here resolve whitespace issues in output; please do not alter them. -->
    <#-- Add the ?html builtin to currentServlet to guard against hacks. 
         Otherwise, the servletPath portion of the URL is rendered verbatim into the HTML -->
    <#compress>
    <#assign bodyClassList = [(currentServlet?html)!]>
    
    <#if user.loggedIn> 
        <#assign bodyClassList = bodyClassList + ["loggedIn"]/>
    </#if> 
    <#list bodyClassList as class>${class}<#if class_has_next> </#if></#list>
    </#compress>
</#assign>

<script>
    // Scripts need to be able to create a URL to the current application.
    applicationContextPath = "${urls.base}"
  
    // What if your current application is not running on the intended server?
    // Use displayPage URLs instead of URIs for links.
	function toDisplayPageUrl(uri) {
		var delimiterHere = Math.max(uri.lastIndexOf('/'), uri
				.lastIndexOf('#'));
		var localname = uri.substring(delimiterHere + 1);
		return applicationContextPath + "/display/" + localname;
	}
</script>