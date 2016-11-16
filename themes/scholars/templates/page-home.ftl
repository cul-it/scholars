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
		<div id="home" class="page">
	    	<#include "identity.ftl">
			<div id="home-layer">
				<header>
					<#include "menu.ftl" />
				</header>
			</div>
			<div id="home-body" class="row">
					<#include "developer.ftl">
				<div id="discover-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 e3e6e9-bkg">
						<p class="home-header">
							Discovery
						</p>
					</div>
				</div>
				<div class="container">
					<div id="discover-content" class="row fff-bkg">
						<div class="col-sm-4 col-md-4 col-lg-4">
							<a class="image-links" href="/scholars/people" >
								<div id="domain-experts" class="image-link-div">
									<div class="discovery-details">
										<span>
										Find a<br/>Domain Expert</span>
									</div>
								</div>
							</a>
							<div class="discovery-text-container">
								<p class="discovery-text">Search by research interests, keywords, and affiliations.</p>
							</div>
						</div>
						<div class="col-sm-4 col-md-4 col-lg-4">
							<a class="image-links" href="/scholars/research" >
								<div id="discover-scholarship" class="image-link-div">
									<div class="discovery-details">
										<span>Explore<br/>Cornell Scholarship</span>
									</div>
								</div>
							</a>
							<div class="discovery-text-container">
								<p class="discovery-text">Search by subject area, and author affiliation.</p>
							</div>		
						</div>
						<div class="col-sm-4 col-md-4 col-lg-4"">
							<a class="image-links" href="/scholars/research#http://vivoweb.org/ontology/core#Grant" >
								<div id="ongoing-research" class="image-link-div">
									<div class="discovery-details">
										<span>Review<br/>Ongoing Research</span>
									</div>
								</div>
							</a>
							<div class="discovery-text-container">
								<p class="discovery-text">Search by topic, investigator, and funding agency.</p>
							</div>
						</div>
					</div>
				</div>
				<div id="visualize-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 e3e6e9-bkg">
						<p class="home-header">
							Visualizations and Downloads
						</p>
					</div>
				</div>
				<div class="container">
					<div id="visualize-content" class="row fff-bkg">
						<div class="col-sm-3 col-md-3 col-lg-3"> 
							<a id="person-to-sa" href="${urls.base}/orgSAVisualization?deptURI=n1234">
								<img width="150px" src="${urls.base}/themes/scholars/images/home-person-sa.png"/>
							</a>
							<div>
								<p>Person to Subject Area</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a id="wordcloud_trigger" href="#">
								<img width="150px" src="${urls.base}/themes/scholars/images/home-wordcloud.png"/>
							</a>
							<div>
								<p>Keyword Cloud</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3"> 
							<a id="collaborations_trigger" href="#">
								<img width="150px" src="${urls.base}/themes/scholars/images/home-collaborations.png"/>
							</a>
							<div>
								<p>Collaborations</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a href="${urls.base}/grantsVisualization">
								<img width="150px" src="${urls.base}/themes/scholars/images/home-grants.png"/>
							</a>
							<div>
								<p>Research Grants</p>
							</div>
						</div>
					</div>
				</div>
				<div id="download-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 e3e6e9-bkg">
						<p class="home-header">
							By the Numbers
						</p>
					</div>
				</div>
				<div class="container">
					<@lh.downloadCounts />
				</div>
			</div> <!-- home-body div -->

			<div id="site_collab_vis"></div>

			<div id="site_wordcloud_vis">
      	      <div id="wc-text-container">
                <span class="text-primary" id="content"></span>
              </div>
              <div id="wcUniv">
                <div id="wcUniv-container">
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
      		    target : '#site_collab_vis',
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


