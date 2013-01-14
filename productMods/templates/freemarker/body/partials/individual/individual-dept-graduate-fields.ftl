<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#if graduateFieldResults?has_content>
    <section id="deptGraduateFields">
        <h2>Faculty Graduate Fields</h2>
        <#assign numberRows = graduateFieldResults?size/>
        <ul role="list" class="deptDetailsList">
            <#list graduateFieldResults as resultRow>
		        <li class="deptDetailsListItem">
		            <a class="gfLink" href="${urls.base}/deptGradFields?deptURI=${individual.uri}&gfURI=${resultRow["gf"]}">
		                ${resultRow["gfLabel"]}
		            </a>
		        </li>
            </#list>
        </ul>
    
    </section>
</#if>


