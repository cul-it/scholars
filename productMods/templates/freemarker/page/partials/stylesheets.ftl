<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for loading stylesheets in the head -->

<!-- vitro base styles (application-wide) -->
<link rel="stylesheet" href="${urls.base}/css/vitro.css" />
<link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/smoothness/jquery-ui.css">
${stylesheets.list()}

<#--temporary until edit controller can include this when needed -->
<link rel="stylesheet" href="${urls.base}/css/edit.css" />