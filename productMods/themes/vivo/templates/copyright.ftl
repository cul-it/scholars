<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#if copyright??>
    <div class="copyright">
        <p>&copy; ${copyright.year?c}
        <#if copyright.url??>
            <a href="${copyright.url}">${copyright.text}</a>
        <#else>
            ${copyright.text}
        </#if>
        </p>
    </div>
</#if>