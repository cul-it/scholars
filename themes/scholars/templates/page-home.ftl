<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->

<@widget name="login" include="assets" />

<#assign string_time = .now?time?string />
<#assign randomized = string_time[string_time?index_of(":")+2..string_time?index_of("M")-3] />
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
			<div id="body" class="row" style="width:100%;margin:-80px 0 0 0;background-color:#fff;min-height: 0;">
					<#include "developer.ftl">
				<div id="discover-header" class="row" style="background-color:#fff;margin:0;padding:60px 50px 0 50px;">
					<div class="col-sm-12 col-md-12 col-lg-12" style="background-color:#e3e6e9;">
						<p style="font-size:20px;font-family: Muli, Arial, Verdana, Helvetica;color:#CC6949;margin:0;padding:6px 0">
							Discovery
						</p>
					</div>
				</div>
				<div id="discover-content" class="row" style="background-color:#fff;margin:0;padding:35px 50px 0 50px;">
					<div class="col-sm-4 col-md-4 col-lg-4">
						<a class="image-links" href="/scholars/people" >
							<div id="domain-experts" class="image-link-div" style="background: #fff url('${urls.base}/themes/scholars/images/home-domain-experts.jpg') no-repeat ${randomized!}0%;background-size: cover;">
								<div style="background-color:rgba(0, 0, 0, 0.5);text-align:center;">
									<span style="opacity:1;color:#fff;font-size:24px;font-family:Muli;font-weight:bold;">
									Find a<br/>Domain Expert</span>
								</div>
							</div>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Search by research interests, keywords, and affiliations.</p>
						</div>
					</div>
					<div class="col-sm-4 col-md-4 col-lg-4">
						<a class="image-links" href="/scholars/research" >
							<div id="discover-scholarship" class="image-link-div">
								<div style="background-color:rgba(0, 0, 0, 0.5);;text-align:center;">
									<span style="opacity:1;color:#fff;font-size:24px;font-family:Muli;font-weight:bold;">Explore<br/>Cornell Scholarship</span>
								</div>
							</div>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Search by subject area, and author affiliation.</p>
						</div>		
					</div>
					<div class="col-sm-4 col-md-4 col-lg-4"">
						<a class="image-links" href="/scholars/research#http://vivoweb.org/ontology/core#Grant" >
							<div id="ongoing-research" class="image-link-div">
								<div style="background-color:rgba(0, 0, 0, 0.5);;text-align:center;">
									<span style="opacity:1;color:#fff;font-size:24px;font-family:Muli;font-weight:bold;">Review<br/>Ongoing Research</span>
								</div>
							</div>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363;">Search by topic, investigator, and funding agency.</p>
						</div>
					</div>
				</div>
				<div id="visualize-header" class="row" style="background-color:#fff;margin:0;padding:40px 50px 0 50px;">
					<div class="col-sm-12 col-md-12 col-lg-12" style="background-color:#e3e6e9;">
						<p style="font-size:20px;font-family: Muli, Arial, Verdana, Helvetica;color:#CC6949;margin:0;padding:6px 0">
							Visualizations and Downloads
						</p>
					</div>
				</div>
				<div id="visualize-content" class="row" style="background-color:#fff;margin:0;padding:10px 5px 0 30px;">
					<div class="col-sm-3 col-md-3 col-lg-3" style="height:300px;text-align:center;padding-top:30px;background-color:#fff;"> 
						<a id="person-to-sa" href="${urls.base}/orgSAVisualization?deptURI=n1234">
							<img width="150px" src="${urls.base}/themes/scholars/images/home-person-sa.png"/>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Person to Subject Area</p>
						</div>
					</div>
					<div class="col-sm-3 col-md-3 col-lg-3" style="height:300px;text-align:center;padding-top:30px;background-color:#fff">
						<a id="wordcloud_trigger" href="#"><img width="150px" src="${urls.base}/themes/scholars/images/home-wordcloud.png"/></a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Keyword Cloud</p>
						</div>
					</div>
					<div class="col-sm-3 col-md-3 col-lg-3" style="height:300px;text-align:center;padding-top:30px;background-color:#fff;"> 
						<a id="collaborations_trigger" href="#">
							<img width="150px" src="${urls.base}/themes/scholars/images/home-collaborations.png"/>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Collaborations</p>
						</div>
					</div>
					<div class="col-sm-3 col-md-3 col-lg-3" style="height:300px;text-align:center;padding-top:30px;background-color:#fff">
						<a href="${urls.base}/grantsVisualization"><img width="150px" src="${urls.base}/themes/scholars/images/home-grants.png"/>
						</a>
						<div style="padding-top:12px;text-align:center;line-height:23px">
							<p style="font-size:18px;font-family: Muli, Arial, Verdana, Helvetica;color:#5e6363">Research Grants</p>
						</div>
					</div>
				</div>
				<div id="download-header" class="row" style="background-color:#fff;margin:0;padding:10px 50px 0 50px;">
					<div class="col-sm-12 col-md-12 col-lg-12" style="background-color:#e3e6e9;">
						<p style="font-size:20px;font-family: Muli, Arial, Verdana, Helvetica;color:#CC6949;margin:0;padding:6px 0">
							By the Numbers
						</p>
					</div>
				</div>
				<@lh.downloadCounts />
			</div> <!-- body div -->
			<div id="collab_vis" style="height:500px;width:700px;z-index:15;border-radius:5px"></div>


			<div id="site_wordcloud_vis" style="height:80%;width:75%;z-index:15;border-radius:5px">
      	      <div style="width: 50%; height: 10px; float:left">
                <span class="text-primary" id="content"></span>
              </div>
              <div id="wcUniv">
                <div style="width: 50%; float:right">
                  <div>
                    <span class="glyphicon glyphicon-info-sign pull-right" 
                      data-toggle="tooltip" 
                      data-toggle="tooltip" 
                      data-original-title="The keyword cloud presents the top 300 keywords extracted from the journal articles published by the Cornell faculty and researchers. <br> The size of each keyword in the cloud is directly proportional to the sum of the count of the faculty/researchers. <br> Bigger the keyword in size is, more the faculty members and researcher used the term in their papers."
                      data-placement="bottom"
                      data-html="true" 
                      data-viewport="#site_wordcloud_vis">
                    </span>
                  </div>
                </div>
              </div>
            </div>

			<script>
			$().ready(function() {
  			  var collab = new ScholarsVis.CollaborationSunburst({
      		    target : '#collab_vis',
      		    modal : true
		      });
		      $('#collaborations_trigger').click(collab.show);

			  var wc = new ScholarsVis.UniversityWordCloud({
      		    target : '#site_wordcloud_vis',
      		    modal : true
		      });
		      $('#wordcloud_trigger').click(wc.show);
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


