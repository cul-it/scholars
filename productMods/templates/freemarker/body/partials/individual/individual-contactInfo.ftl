<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Contact info on individual profile page -->

<#-- CU directory link -->
<#assign netid = individual.selfEditingId!>
<#if netid?has_content>
    <p class="contact-information">
        <img class="middle" src="${urls.images}/individual/contactInformationIcon.gif" alt="Contact information icon" />
        <a href="http://www.cornell.edu/search/?tab=people&netid=${netid}" title="Cornell University directory entry for ${netid}" target="_blank">Contact information</a>
    </p>
</#if>
          
<#-- Links -->  
<@p.vitroLinks propertyGroups namespaces editable "individual-urls-people" />