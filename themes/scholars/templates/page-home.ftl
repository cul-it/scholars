<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->

<@widget name="login" include="assets" />

<#assign string_time = .now?time?string />
<#assign randomized = string_time[string_time?index_of(":")+2..string_time?index_of("M")-3] />
<#import "lib-home-page.ftl" as lh>
<!DOCTYPE html>
<html lang="en">
    <head>
        <#include "head.ftl">
        <#include "homeScripts.ftl">
    </head>
	<#assign navbarClass = "homepage"/>
	<#assign backsplashDisplay = ""/>
	<#assign navbarLogoDisplay = "display:none;"/>
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
				<div class="container-fluid scholars-home-container">
					<div id="discover-content" class="row fff-bkg">
						<div id="expert-search-link" class="col-sm-4 col-md-4 col-lg-4 search-links">
							<div id="domain-experts" class="search-link-div">
								<div class="discovery-details">
									<span>
										Find a<br/>Domain Expert
									</span>
								</div>
								<div id="expert-search" class="home-search-container">
									<form id="de-search-form" action="${urls.base}/domainExpert" name="search" role="search" accept-charset="UTF-8" method="POST"> 
										<input id="de-search-vclass" type="hidden" name="vclassId" value="http://purl.obolibrary.org/obo/BFO_0000002" />
										<input id="de-search-input" class="home-search-input subject-search" type="text" name="querytext" value="${querytext!}" />
										<input id="de-search-submit" class="home-page-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="GO" />
										<div class="search-radio-container">
											<input type="radio" name="querytype" value="subject" checked> by subject or keyword
								   			<input id="by-name-radio" type="radio" name="querytype" value="name"> by name
								  		</div>
									</form>
								</div>
							</div>
						</div>
						<div id="res-search-link" class="col-sm-4 col-md-4 col-lg-4 search-links" >
								<div id="discover-scholarship" class="search-link-div">
									<div class="discovery-details">
										<span>
											Explore<br/>Research & Scholarship
										</span>
									</div>
									<div id="research-search" class="home-search-container">
										<form id="res-search-form" action="${urls.base}/scholarship" name="search" role="search" accept-charset="UTF-8" method="POST"> 
											<input id="res-search-vclass" type="hidden" name="vclassId" value="http://purl.obolibrary.org/obo/BFO_0000002" />
											<input id="res-search-input" class="home-search-input" type="text" name="querytext" value="${querytext!}" />
											<input id="res-search-submit" class="home-page-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="GO" />
												<input type="hidden" name="querytype" value="all" /> 
										</form>
									</div>
								</div>
						</div>
						<div id="unit-search-link" class="col-sm-4 col-md-4 col-lg-4 search-links">
								<div id="ongoing-research" class="search-link-div">
									<div class="discovery-details">
										<span>Review<br/>Academic Units</span>
									</div>
									<div id="unit-placeholder" class="discovery-details">
										<span>&#8212 Coming Soon &#8212</span>
									</div>
								</div>
						</div>
					</div>
				</div>
				<div id="visualize-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 home-divider">
						<p class="home-header">
							The Visualizations
						</p>
					</div>
				</div>
				<div class="container-fluid scholars-home-container">
					<div id="visualize-content" class="row fff-bkg">
						<div class="col-sm-3 col-md-3 col-lg-3"> 
							<a id="person-to-sa" href="${urls.base}/orgSAVisualization">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-person-sa.png"/>
							</a>
							<div>
								<p>Research Interests</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a href="${urls.base}/homeWordcloudVisualization">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/wordcloud-icon.png"/>
							</a>
							<div>
								<p>Research Keywords</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3"> 
							<a href="${urls.base}/homeWorldmapVisualization">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-worldmap.png"/>
							</a>
							<div>
								<p>Global Collaborations</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a href="${urls.base}/grantsVisualization">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-grants.png"/>
							</a>
							<div>
								<p>Research Grants</p>
							</div>
						</div>
					</div>
				</div>


				<div id="partners-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 home-divider">
						<p class="home-header">
							Partner Alliance
						</p>
					</div>
				</div>
				<div class="container-fluid scholars-home-container">
					<div id="partners-row1" class="row fff-bkg" style="margin:30px 30px 30px 30px;">
					<div class="col-sm-4 col-md-4 col-lg-4"> 
					  <div id="eng-text" style="padding:0 0 10px;font-size:18px;">
						<p><a id="eng-link" href="${urls.base}/display/org73341">College of Engineering</a></p>
					  </div>
						<a href="${urls.base}/display/org73341">
							<div id="eng-image" style="margin-right:-40px"> 
							</div>
						</a>
					</div>
						<div id="jgsm-text" class="col-sm-3 col-md-3 col-lg-3" style="padding-top:40px;margin-left: 40px;"> 
							<p><a id="jgsm-link" href="${urls.base}/display/org74741">Samuel Curtis Johnson<br/>School of Management</a></p>
						</div>
						<div class="col-sm-4 col-md-4 col-lg-4" style="padding-top:36px"> 
							<a href="${urls.base}/display/org74741">
								<div id="jgsm-image" style="margin-right:-40px"> 
								</div>
							</a>
						</div>
					</div>
				</div>


				<div id="download-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 home-divider">
						<p class="home-header">
							By the Numbers
						</p>
					</div>
				</div>
				<div class="container-fluid scholars-home-container">
					<@lh.downloadCounts />
				</div>
			</div> <!-- home-body div -->

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
		<script>
			var baseUrl = "${urls.base}";
			var imagesUrl = "${urls.images}";
		</script>
        <script type="application/ld+json">
        	{
  				"@context": "http://schema.org",
  				"@type": "WebSite",
  				"name": "Scholars@Cornell",
  				"alternateName": "Scholars at Cornell",
  				"url": "https://scholars.cornell.edu/",
				"description": "Scholars@Cornell is a data and visualization service developed at Cornell University Library with the goal of improving the visibility of Cornell research and enabling discovery of explicit and latent patterns of scholarly collaboration.",
  				"sameAs" :[
       				"https://twitter.com/ScholarsCornell"
   				]
			}
		</script>
    </body>
</html>
