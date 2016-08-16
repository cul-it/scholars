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
		<div id="base-page" class="page" style=";margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
       		<#include "identity.ftl">
        	<header style="display:block;margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
				<#include "menu.ftl" />
			</header>
		</div> <!-- #base-page -->
		<#include "developer.ftl">
		<div id="body" style="width:100%;margin:0;background-color:#f1f2f3;min-height: 0;padding:30px 70px 0 70px">	
        	${body}
	  	</div> <!-- body div -->
        <#include "footer.ftl" />
    </body>
</html>


<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />
<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />


<#--
<section id="search" role="region" style="z-index:1000;display:none">
     <fieldset>
         <legend>Search form</legend>

         <form id="search-form" action="${urls.search}" name="search" role="search" accept-charset="UTF-8" method="POST"> 
             <div id="search-field">
                 <input type="text" name="querytext" class="search-vivo" value="${querytext!}" autocapitalize="off" />
                 <input type="submit" value="Search" class="search">
             </div>
         </form>
     </fieldset>
 </section>
-->