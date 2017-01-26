<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for scripts that must be loaded in the head -->
<script>
var i18nStrings = {
    allCapitalized: '${i18n().all_capitalized}',
};
</script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js"></script>
<script type="text/javascript" src="${urls.base}/js/vitroUtils.js"></script>

<#-- script for enabling new HTML5 semantic markup in IE browsers -->
<!--[if lt IE 9]>
<script type="text/javascript" src="${urls.base}/js/html5.js"></script>
<![endif]-->

${headScripts.list()} 
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
