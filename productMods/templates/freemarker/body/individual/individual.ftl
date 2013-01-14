<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default VIVO individual profile page template (extends individual.ftl in vitro) -->

<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

<#assign individualProductExtension>
    <#-- Include for any class specific template additions -->
    ${classSpecificExtension!}
   
    <!--PREINDIVIDUAL OVERVIEW.FTL-->
    <#if individual.mostSpecificTypes?seq_contains("Academic Department")>
            <div id="activeGrantsLink" style="float:right;width:200px;<#if editable>margin-top:54px<#else>margin-top:30px</#if>">
            <img src="${urls.base}/images/individual/arrow-green.gif">
                <a href="${urls.base}/deptGrants?individualURI=${individual.uri}">
                    View all active grants
                </a>    
            </div>
    </#if>
    <#include "individual-webpage.ftl"> 
    <#include "individual-overview.ftl">
    <#if individual.mostSpecificTypes?seq_contains("Academic Department")>
        <#include "individual-dept-research-areas.ftl">
    </#if>
        </section> <!-- end section #individual-info -->
    </section> <!-- end section #individual-intro -->
    <!--postindiviudal overview.ftl-->
</#assign>

<#include "individual-vitro.ftl">
<script>
    var individualLocalName = "${individual.localName}";
    <#if individual.mostSpecificTypes?seq_contains("Academic Department")>
        
    </#if>
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-property-groups.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/amplify/amplify.store.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/propertyGroupControls.js?vers=1.5.1"></script>')}

