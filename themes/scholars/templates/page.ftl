<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#import "lib-list.ftl" as l>
<!DOCTYPE html>
<html lang="en">
    <head>
        <#include "head.ftl">
    </head>
	<#assign navbarClass = "class='fixed'"/>
    <#assign backsplashDisplay = "display:none;"/>
    <#assign navbarLogoDisplay = "display:inline;"/>
	<body class="${bodyClasses!}" onload="${bodyOnload!}">
		<div id="base-page" class="page">
       		<#include "identity.ftl">
        	<header>
				<#include "menu.ftl" />
			</header>
		</div> <!-- #base-page -->
			<#include "developer.ftl">
		<div id="body">	
        	${body}
	  	</div> <!-- body div -->
        <#include "footer.ftl" />
    </body>
</html>


<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />
<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />
