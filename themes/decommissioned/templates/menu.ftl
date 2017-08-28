<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

</header>

<#include "developer.ftl">


<div id="wrapper-content" role="main">
    <#if flash?has_content>
        <#if flash?starts_with("Welcome") >
            <section  id="welcome-msg-container" role="container">
                <section  id="welcome-message" role="alert">${flash}</section>
            </section>
        <#else>
            <section id="flash-message" role="alert">
                ${flash}
            </section>
        </#if>
    </#if>
    
    <!--[if lte IE 8]>
    <noscript>
        <p class="ie-alert">This site uses HTML elements that are not recognized by Internet Explorer 8 and below in the absence of JavaScript. As a result, the site will not be rendered appropriately. To correct this, please either enable JavaScript, upgrade to Internet Explorer 9, or use another browser.</p>
    </noscript>
    <![endif]-->