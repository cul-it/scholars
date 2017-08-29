<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying search error message -->
<script>
	window.location = "${urls.base}";
</script>

<#if title??>
    <h2>${title?html}</h2>
</#if>

<p>
${message?html}
</p>
<#include "search-help.ftl" >