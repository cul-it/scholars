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
<#elseif gfDepartmentResults?has_content>
<section id="graduateFieldDepts" style="clear:left">
    <h2>Affiliated Departments</h2>
    <#assign numberRows = gfDepartmentResults?size/>
    <ul id="individual-hasResearchArea" role="list">
        <#list gfDepartmentResults as resultRow>
			<#assign departmentURI = resultRow["dept"]?substring(resultRow["dept"]?last_index_of("/"))/>
	        <li class="raLink">
	            <a class="raLink" href="${urls.base}/display${departmentURI}">
	                ${resultRow["deptLabel"]}
	            </a>
	        </li>
        </#list>
    </ul>
</section>
</#if>


