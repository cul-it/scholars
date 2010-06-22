<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "partials/doctype.html">

<#include "partials/head.ftl">

<body>
    <div id="wrap">
       <#include "partials/identity.ftl">
        <div id="contentwrap">
          <#-- Note to UI team: do not change this div without also making the corresponding change in menu.jsp -->
          <#include "partials/menu.ftl">

          <#-- <#include "/partials/breadcrumbs.ftl"> -->
          <div class="pagecontent">
            <#-- We don't do title here because some pages don't get a title, or it may not be the same as the <title> text.
            <h2>${title}</h2> -->               
            ${body} 
          </div> <!-- pagecontent -->
        </div> <!-- contentwrap -->
      <div class="push"></div>
    </div> <!-- wrap -->  
    <div id="footer-wrap">
     <#include "partials/scripts.ftl">
    </div> <!-- footer-wrap -->
</body>
</html>

<#-- Three ways to add a stylesheet:

A. In theme directory:
${stylesheets.addFromTheme("/sample.css");
${stylesheets.add(stylesheetDir + "/sample.css")}

B. Any location
${stylesheets.add("/edit/forms/css/sample.css"}

-->