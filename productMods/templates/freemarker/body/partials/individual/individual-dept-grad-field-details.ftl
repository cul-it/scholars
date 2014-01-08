<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#if deptGradFields?has_content>
    <section id="pageList">
        <#list deptGradFields as firstRow>
        <div class="tab">
            <h2>${firstRow["gfLabel"]}</h2>
            <p>Here are the faculty in the ${firstRow["deptLabel"]} department who are members of this graduate field. <a href="${urls.base}/display${firstRow["?gradField"]?substring(firstRow["?gradField"]?last_index_of("/"))}" title="view all cornell faculty">View all Cornell faculty who are members of this field.</a></p>
        </div>
        <#break>
        </#list>

    <section id="deptGraduateFields">
        <ul role="list"  class="deptDetailsList">
            <#list deptGradFields as resultRow>
		        <li class="deptDetailsListItem">
		                <a href="${urls.base}/individual${resultRow["person"]?substring(resultRow["person"]?last_index_of("/"))}">${resultRow["personLabel"]}</a>
		        </li>
            </#list>
        </ul>
    
    </section>

</#if>

</section>
