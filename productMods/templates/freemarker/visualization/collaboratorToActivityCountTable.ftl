<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<table id='${tableID}'>
    <caption>
    ${tableCaption}
    </caption>
    <thead>
    <tr>
        <th>
        Author (faculty)
        </th>
        <th>
        ${tableActivityColumnName}
        </th>
    </tr>
    </thead>
    <tbody>

    <#assign addLine = true />
    <#list tableContent.collaborators as collaborator>
				<#if collaborator.isVCard>
					<#assign displayLabel = collaborator.collaboratorURI/>
				<#else>
					<#assign displayLabel = collaborator.collaboratorName/>
				</#if>
        <#if collaborator_index gt 0 >
        <#if addLine && collaborator.isVCard>
            <#assign addLine = false />
				    <tr>
				        <th style="background-color:#eaeaea;font-size: 14px;padding: 5px;vertical-align: top;text-align: left;">
				        Author (non-faculty)
				        </th>
				        <th style="background-color:#eaeaea;font-size: 14px;padding: 5px;vertical-align: top;text-align: left;">
				        ${tableActivityColumnName}
				        </th>
				    </tr>
        </#if>
            <tr>
                <td>
                ${displayLabel}
                </td>
                <td>
                ${tableContent.collaborationMatrix[0][collaborator_index]}
                </td>
            </tr>
        </#if>
    </#list>

    </tbody>
</table>
