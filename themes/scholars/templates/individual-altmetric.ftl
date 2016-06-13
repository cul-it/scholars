<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Overview on individual profile page -->
<style>
div.altmetric-hidden {
	display:none;
}
</style>
<#if altmetricEnabled??>
    <#if doi?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
            <div class="individual-altmetric-badge">
                <div class="altmetric-embed"
                     style="float: left; padding:14px 0 0 26px; margin-bottom: -10px"
                     data-badge-type="donut"
                     <#if altmetricPopover??>data-badge-popover="right"</#if>
                     <#if altmetricDetails??>data-badge-details="${altmetricDetails}"</#if>
                     <#if altmetricHideEmpty??>data-hide-no-mentions="true"</#if>
                     data-link-target="_blank"
                     data-doi="${doi!}">
                </div>
            </div>
    <#else>
           <#if pmid?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
	           <div class="individual-altmetric-badge">
	               <div class="altmetric-embed"
	                    style="float: left; padding:14px 0 0 26px"
	                    data-badge-type="donut"
	                    <#if altmetricPopover??>data-badge-popover="right"</#if>
	                    <#if altmetricDetails??>data-badge-details="${altmetricDetails}"</#if>
	                    <#if altmetricHideEmpty??>data-hide-no-mentions="true"</#if>
	                    data-link-target="_blank"
	                    data-doi="${pmid!}">
	               </div>
	           </div>
        </#if>
    </#if>
</#if>
