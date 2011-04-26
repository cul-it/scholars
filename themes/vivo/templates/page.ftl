<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#include "doctype.html">

<#include "head.ftl">

<body>
    <div id="wrap">
       <#include "identity.ftl">
        <div id="contentwrap">
          <#-- Note to UI team: do not change this div without also making the corresponding change in menu.jsp -->
          <#include "menu.ftl">

          <#-- <#include "breadcrumbs.ftl"> -->
          <div class="pagecontent">
            <#-- We don't do title here because some pages don't get a title, or it may not be the same as the <title> text.
            <h2>${title}</h2> -->               
            ${body} 
          </div> <!-- pagecontent -->
        </div> <!-- contentwrap -->
      <div class="push"></div>
    </div> <!-- wrap -->  
    <div id="footer-wrap">
      <#include "footer.ftl">
    </div> <!-- footer-wrap -->
    <#include "scripts.ftl">
</body>
</html>

