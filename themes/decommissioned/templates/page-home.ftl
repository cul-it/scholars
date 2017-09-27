<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->
<!DOCTYPE html>
<html lang="en" style="background-color:#fff">
    <head>
        <#include "head.ftl">
        <#if geoFocusMapsEnabled >
            <#include "geoFocusMapScripts.ftl">
        </#if>
        <#include "homeScripts.ftl">
    </head>
    <#--  class="${bodyClasses!}" -->
    <body class="${bodyClasses!}">

        <#include "identity.ftl">

	  <div style="height:100%">
        <section id="intro" role="region" style="width:80%;margin:20px 0 0 70px;">
        	<h2 style="margin-bottom:20px">VIVO has been decommissioned.</h2>
        	<div style="padding-left: 40px">
        		<p>Cornell University Library is no longer maintaining the VIVO web site. Although the site will remain live, no software updates or data ingests will take place. Read-only versions of faculty and staff profile pages will still be accessible via their URLs.</p>
        		<p style="background-color: #d9edf7;border: 1px solid #bcdff1;border-radius: 4px;padding: 12px 0 12px 12px;color: #31708f;margin-left: 24px;margin-right: 36px;">A new site, <a href="http://scholars.cornell.edu"><b>Scholars@Cornell</b></a> is now available. Scholars@Cornell is an interactive knowledge network that provides visualizations for exploring the scholarly record of faculty members, researchers, and departments at Cornell University.</p>
				<p>Scholars@Cornell incorporates the VIVO core code, which is now maintained at <a href="http://duraspace.org/">Duraspace</a>. Refer to the <a href="http://duraspace.org/registry/vivo">VIVO registry</a> for a list of institutions that have VIVO sites. In addition, the <a href="http://openvivo.org/">OpenVIVO</a> web site is available to researchers of all disciplines.</p>
				<p style="padding-bottom:90px">If you have questions either about the VIVO site or Scholars@Cornell, please <a href="${urls.contact!}">contact us</a>.</p>
        	</div>
			<div style="margin-top:90px;">
	        <#include "footer.ftl">
		</section>
	</div>
        <script>  
		$("footer").css("margin-left","-30px").css("border-top","1px solid #c9c7bf").css("padding-right","120px");
		$("div.wrapper").css("width","115%");
		$("#footer-nav").css("margin-top","-12px");
            var i18nStrings = {
                researcherString: '${i18n().researcher}',
                researchersString: '${i18n().researchers}',
                currentlyNoResearchers: '${i18n().currently_no_researchers}',
                countriesAndRegions: '${i18n().countries_and_regions}',
                countriesString: '${i18n().countries}',
                regionsString: '${i18n().regions}',
                statesString: '${i18n().map_states_string}',
                stateString: '${i18n().map_state_string}',
                statewideLocations: '${i18n().statewide_locations}',
                inString: '${i18n().in}',
                noFacultyFound: '${i18n().no_faculty_found}',
                placeholderImage: '${i18n().placeholder_image}',
                viewAllFaculty: '${i18n().view_all_faculty}',
                viewAllString: '${i18n().view_all}',
                viewAllDepartments: '${i18n().view_all_departments}',
                noDepartmentsFound: '${i18n().no_departments_found}'
            };
            // set the 'limmit search' text and alignment
            if  ( $('input.search-homepage').css('text-align') == "right" ) {       
                 $('input.search-homepage').attr("value","${i18n().limit_search} \u2192");
            }  
        </script>
    </body>
</html>