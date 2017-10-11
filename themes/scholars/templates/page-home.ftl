<#-- $This file is distributed under the terms of the license in /doc/license.txt$  -->

<@widget name="login" include="assets" />

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
										<input id="de-search-submit" class="home-page-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="GO"  onclick="javascript:_paq.push(['trackEvent', 'Search', 'Homepage', 'Find A Domain Expert']);" />
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
											<input id="res-search-submit" class="home-page-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="GO"  onclick="javascript:_paq.push(['trackEvent', 'Search', 'Homepage', 'Explore Research and Scholarship']);"/>
												<input type="hidden" name="querytype" value="all" /> 
										</form>
									</div>
								</div>
						</div>
						<div id="unit-search-link" class="col-sm-4 col-md-4 col-lg-4 search-links">
								<div id="ongoing-research" class="search-link-div">
									<form id="unit-search-form" action="${urls.base}/academicUnits" name="search" role="search" accept-charset="UTF-8" method="POST"> 
										<input id="unit-search-vclass" type="hidden" name="vclassId" value="http://xmlns.com/foaf/0.1/Organization" />
										<input type="hidden" name="querytype" value="colleges" /> 
									</form>
									<div class="discovery-details">
										<a class="image-links" id="browse-units-link" href="javascript:" onclick="javascript:_paq.push(['trackEvent', 'Search', 'Homepage', 'Browse Academic Units']);"><span>Browse<br/>Academic Units</span></a>
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
							<a id="person-to-sa" href="${urls.base}/orgSAVisualization" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Homepage', 'Research Interest']);">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-person-sa.png"/>
							</a>
							<div>
								<p>Research Interests</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a href="${urls.base}/homeWordcloudVisualization" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Homepage', 'Keyword Clouds']);">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/wordcloud-icon.png"/>
							</a>
							<div>
								<p>Keyword Clouds</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3"> 
							<a href="${urls.base}/homeWorldmapVisualization" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Homepage', 'Global Collaborations']);">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-worldmap.png"/>
							</a>
							<div>
								<p>Global Collaborations</p>
							</div>
						</div>
						<div class="col-sm-3 col-md-3 col-lg-3">
							<a href="${urls.base}/grantsVisualization" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Homepage', 'Grants and Contracts']);">
								<img id="vizIcon" width="190px" src="${urls.base}/themes/scholars/images/home-grants.png"/>
							</a>
							<div>
								<p>Grants and Contracts</p>
							</div>
						</div>
					</div>
				</div>


				<div id="partners-header" class="row fff-bkg">
					<div class="col-sm-12 col-md-12 col-lg-12 home-divider">
					</div>
				</div>
				
				
	<div class="container-fluid scholars-home-container">
   		<div id="partners-row1" class="row fff-bkg">
   			<div class="col-sm-4 col-md-4 col-lg-4 nopadding-nomargin">
				<div id="partners-row1a" class="row fff-bkg nopadding-nomargin">
					<div id="partners-spacer" class="col-sm-12 col-md-12 col-lg-12 nopadding-nomargin"></div>
				</div>
				<div id="partners-row1b" class="row fff-bkg nopadding-nomargin">
   					<div id="partners-container" class="col-sm-12 col-md-12 col-lg-12 nopadding-nomargin"> 
   						<p class="home-header">Our Partners</p>
   						<p id="partners-text">We're currently collaborating with these academic units to ensure the integrity of Scholars@Cornell data. <a href="${urls.base!}/contact">Become a partner.</a></p>
   					</div>
				</div>
			</div>
   			<div class="col-sm-8 col-md-8 col-lg-8 nopadding-nomargin">
				<div id="partners-row1c" class="row fff-bkg nopadding-nomargin">
					<div class="col-sm-2 col-md-2 col-lg-2 nopadding-nomargin"></div>
	   				<div class="col-sm-6 col-md-6 col-lg-6 nopadding-nomargin">
	   					<a href="${urls.base}/display/org73341" onclick="javascript:_paq.push(['trackEvent', 'Scholars Affiliates', 'Homepage', 'Engineering']);">
			   				<div id="eng-image"><img src="${urls.theme!}/images/eng-logo.png"></div>
			   			</a>
	   				</div>
					<div class="col-sm-2 col-md-2 col-lg-2 nopadding-nomargin"></div>
				</div>
				<div id="partners-row1d" class="row fff-bkg">
	   				<div class="col-sm-7 col-md-7 col-lg-7 nopadding-nomargin"></div>	
	   				<div class="col-sm-5 col-md-5 col-lg-5 nopadding-nomargin"> 
	   					<a href="${urls.base}/display/org74741" onclick="javascript:_paq.push(['trackEvent', 'Scholars Affiliates', 'Homepage', 'Johnson School']);">
							<div id="jgsm-image"><img src="${urls.theme!}/images/johnson-logo.png"></div>
						</a>
	   				</div>
				</div>
			</div>
		</div>
		<div id="partners-row2" class="row fff-bkg"> 
	   		<div class="col-sm-5 col-md-5 col-lg-5 nopadding-nomargin"></div>
	   		<div class="col-sm-3 col-md-3 col-lg-3 nopadding-nomargin"> 
	   			<a id="bti-link" href="${urls.base}/display/org98030" onclick="javascript:_paq.push(['trackEvent', 'Scholars Affiliates', 'Homepage', 'BTI']);">
					<div id="bti-image"><img src="${urls.theme!}/images/bti-logo.png"></div>
				</a>
	   		</div>
	   	</div>
   	</div>
  </div> <!-- home-body div -->
  	<@lh.downloadCounts />

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
