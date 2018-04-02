<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<meta charset="utf-8" />
<!-- Google Chrome Frame open source plug-in brings Google Chrome's open web technologies and speedy JavaScript engine to Internet Explorer-->
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

<title>${(title?html)!siteName!}</title>

<#-- VIVO OpenSocial Extension by UCSF -->
<#if openSocial??>
    <#if openSocial.visible>
        <#-- Required to add these BEFORE stylesheets.flt and headScripts.ftl are processed -->
        ${stylesheets.add('<link rel="stylesheet" href="${urls.theme}/css/openSocial/gadgets.css" />')}			
        ${headScripts.add('<script type="text/javascript" src="${openSocial.containerJavascriptSrc}"></script>',
                          '<script type="text/javascript" language="javascript">${openSocial.gadgetJavascript}</script>',
                          '<script type="text/javascript" src="${urls.base}/js/openSocial/orng.js"></script>')}
    </#if>	
</#if>	
<link rel="icon" href="${urls.base}/favicon.ico?version=2.0">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<#include "stylesheets.ftl">
<#if (version.label?length > 12 ) >
	<#assign revision = version.label[version.label?length-12..] />
	<#assign revision = revision?replace(" tag","") />
</#if>
<link rel="stylesheet" href="${urls.theme}/css/screen.css?version=${revision!}" />
<!-- Emergency banner -->
<script src="https://embanner.univcomm.cornell.edu/OWC-emergency-banner.js" type="text/javascript"> </script>
${headScripts.add('<script type="text/javascript" src="${urls.theme}/js/scholarsSearch.js"></script>')}
${headScripts.add('<script type="text/javascript" src="${urls.theme}/js/scholarsUtils.js"></script>')}
<#include "headScripts.ftl">

<!--[if lt IE 7]>
<link rel="stylesheet" href="${urls.theme}/css/ie6.css" />
<![endif]-->

<!--[if IE 7]>
<link rel="stylesheet" href="${urls.theme}/css/ie7.css" />
<![endif]-->

<!--[if (gte IE 6)&(lte IE 8)]>
<script type="text/javascript" src="${urls.base}/js/selectivizr.js"></script>
<![endif]-->

<#-- Inject head content specified in the controller. Currently this is used only to generate an rdf link on 
an individual profile page. -->
${headContent!}

<link rel="shortcut icon" type="image/x-icon" href="${urls.base}/favicon.ico">