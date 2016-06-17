<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->

<@widget name="login" include="assets" />

<#-- 
        With release 1.6, the home page no longer uses the "browse by" class group/classes display. 
        If you prefer to use the "browse by" display, replace the import statement below with the
        following include statement:
        
          <#include "browse-classgroups.ftl">
            
        Also ensure that the homePage.geoFocusMaps flag in the runtime.properties file is commented
        out.
-->
<#import "lib-home-page.ftl" as lh>
<#import "lib-vivocornell-home-page.ftl" as lvh>
<!DOCTYPE html>
<html lang="en">
    <head>
        <#include "head.ftl">
        <#include "homeScripts.ftl">
    </head>
	<#assign navbarClass = "homepage"/>
	<#assign backsplashDisplay = ""/>
	<#assign navbarLogoDisplay = "display:none;"/>
    <#-- builds a json object that is used by js to render the academic departments section -->
    <@lvh.listResearchFacilities />
    <#-- supplies the faculty count to the js function that generates a random row number for the solr query -->
    <@lh.facultyMemberCount  vClassGroups! />

    <body class="${bodyClasses!}" onload="${bodyOnload!}">
		<div id="home" class="page" style=";margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
	    	<#include "identity.ftl">
			<div id="home-layer" style="height: 228px; background: rgba(255, 255, 255) none repeat scroll 0% 0%;margin:0;padding:0;border:0;vertical-align:baseline">
				<header style="display:block;margin:0;padding:0;height:100%;min-height:100%;border:0;vertical-align:baseline">
					<#include "menu.ftl" />
				</header>
			</div>
			<#include "developer.ftl">
			<div id="body" style="width:100%;margin:0;background-color:#f1f2f3;min-height: 0;padding:50px 70px 0 70px">
				<div id="row1" class="row" style="background-color:#f1f2f3">
					<div class="col-sm-4 col-md-4 col-lg-4" id="visualizations" style="border: 1px solid #cdd4e7;border-top:5px solid #CC6949;position:relative;background-color: #fff">
						<#-- <h4 style="border-bottom:1px solid #CC6949;background:#403d3e url('${urls.base}/themes/scholars/images/viz_header_test.png') no-repeat 30% 50%;;margin:0 -15px;padding:30px;;color:#fff;text-align:center;margin-bottom:16px;font-size:20px;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Visualizations</h4> -->
						<h4 style="color:#5f5858;text-align:center;margin-top:16px;margin-bottom:16px;font-size:20px;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Visualizations</h4>
						<div class="row" style="background-color:#f1f2f3;margin-top:30px">
							<div class="col-sm-12 col-md-12 col-lg-12" style="text-align:center;background-color:#fff">
								<a id="collaborations_trigger" href="#"><img width="54%" src="${urls.base}/themes/scholars/images/collab2.png"/></a>
								<p style="padding-top:4px;font-size:16px;color:#CC6949">Collaborations</p>
							</div>
							<div class="col-sm-12 col-md-12 col-lg-12" style="text-align:center;padding-top:16px;background-color:#fff">
								<a href="${urls.base}/grantsVisualization"><img width="50%" src="${urls.base}/themes/scholars/images/grants.png"/></a>
								<p style="padding-top:4px;font-size:16px;color:#CC6949">Grants</p>
							</div>
							<div class="col-sm-12 col-md-12 col-lg-12" style="text-align:center;padding-top:16px;background-color:#fff">
								<img width="55%" src="${urls.base}/themes/scholars/images/wordcloud.png"/>
								<p style="padding-top:4px;font-size:16px;color:#CC6949">Subject Areas</p>
							</div>
							<div class="col-sm-12 col-md-12 col-lg-12" style="display:none;text-align:center;padding-top:16px;background-color:#fff">
								<img width="50%" src="co-authors.png"/>
								<p style="padding-top:6px"><a href="#">Co-author Networks</a></p>
							</div>
						</div>
					</div>
					<div class="col-sm-1 col-md-1 col-lg-1">
					</div>
					<div class="col-sm-7 col-md-7 col-lg-7">
						<div class="row" style="background-color:#f1f2f3">
		        			<!-- List of four randomly selected faculty members -->
		        			<@lh.facultyMbrHtml />
						</div>
						<div class="row" style="background-color:#f1f2f3">
			    			<!-- Statistical information relating to property groups and their classes; displayed horizontally, not vertically-->
			    			<@lh.allClassGroups vClassGroups! />
						</div>
					</div>
				</div> <!-- row1 -->
			</div> <!-- body div -->
			<div id="collab_vis" style="z-index:15;border-radius:5px"></div>

			<script>
			$().ready(function() {
			  loadVisualization({
		    	modal : true, 
			    target : '#collab_vis',
			    trigger : '#collaborations_trigger',
			    url : "${urls.base}/api/dataRequest?action=collaboration_sunburst",
			    transform : transformCollab,
			    display : sunburst,
			    height : 500,
			    width : 700
			  });
			});
			</script>
	        <#include "footer.ftl" />
		</div> <!-- home -->
        <script>       
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
        </script>
    </body>
</html>
<#-- <#if !settings.developer_enabled>margin-top:-60px<#else>margin-top:10px</#if>  -->