<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of positions for the individual -->
<#assign positions = propertyGroups.pullProperty("${core}relatedBy", "${core}Position")!>
<#if positions?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
    <#assign localName = positions.localName>
    <h2 id="${localName}" class="mainPropGroup" title="${positions.publicDescription!}" style="padding-top:10px;border-bottom:1px solid #b9b9b9"> <@p.addLink positions editable /> <@p.verboseDisplay positions /></h2>
	<#assign positions>
		<@p.objectProperty positions editable />
	</#assign>
    <ul id="individual-personInPosition" role="list">
        <#compress>${positions!}</#compress>
    </ul> 
</#if> 
