<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Default VIVO individual profile page template (extends individual.ftl in vitro) -->

<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

<#assign individualProductExtension>
    <#-- Include for any class specific template additions -->
    ${classSpecificExtension!}
   
    <!--PREINDIVIDUAL OVERVIEW.FTL-->
    <#include "individual-webpage.ftl"> 
    <#include "individual-overview.ftl">
        </section> <!-- end section #individual-info -->
    </section> <!-- end section #individual-intro -->
    <!--postindiviudal overview.ftl-->
</#assign>

<#include "individual-vitro.ftl">
<script>
    var individualLocalName = "${individual.localName}";
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-property-groups.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/amplify/amplify.store.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/propertyGroupControls.js?vers=1.5.1"></script>')}

