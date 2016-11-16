<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- List of positions for the individual -->
<#assign positions = propertyGroups.pullProperty("${core}relatedBy", "${core}Position")!>
<#if positions?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
    <#assign localName = positions.localName>
    <span> <@p.addLink positions editable /> <@p.verboseDisplay positions /></span>
	<#assign positions>
		<@p.objectProperty positions editable />
	</#assign>
    <ul id="individual-personInPosition" role="list">
        <#compress>${positions!}</#compress>
    </ul> 
</#if>
