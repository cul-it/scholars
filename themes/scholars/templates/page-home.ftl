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
					<div class="col-sm-4 col-md-4 col-lg-4 scholars-container" id="visualizations">
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
								<a id="wordcloud_trigger" href="#"><img width="54%" src="${urls.base}/themes/scholars/images/wordcloud.png"/></a>
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
		        		<#--	<@lh.facultyMbrHtml /> -->


					    <div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="fac_researchers">
						<h4 style="color:#5f5858;text-align:center;margin-top:16px;margin-bottom:16px;font-size:20px;font-family:Lucida Sans Unicode, Helvetica, sans-serif">Faculty and Researchers</h4>
							<div class="row" style="background-color:#fff">
					        		<div id="research-faculty-mbrs" style="margin-top:0">
					            		<!-- populated via an ajax call -->
					            		<ul id="facultyThumbs">
					            		</ul>
						  			</div>
								</div>
						    </div>


						<#-- -->
						</div>
						<div class="row" style="background-color:#f1f2f3">
			    			<!-- Statistical information relating to property groups and their classes; displayed horizontally, not vertically-->
			    			<@lh.allClassGroups vClassGroups! />
						</div>
					</div>
				</div> <!-- row1 -->





				<ul id="facultyThumbstest">
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n864/thumbnail_fg.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Ffvg3">Guimbretiere, Francois V.</a></h1><span class="title">Associate Professor, Information Science</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n7259/thumbnail_nap.jpg" width="80">
			        	<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fna424">Andarawis-Puri, Nelly</a></h1><span class="title">Assistant Professor, Mechanical and Aerospace Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n4370/thumbnail_gx.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fhgx2">Xing, Huili Grace</a></h1><span class="title">Professor, Electrical and Computer Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n6709/thumbnail_jm.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fjfm37">Martinez, Jose F.</a></h1><span class="title">Associate Professor, Electrical and Computer Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n6865/thumbnail_hunter.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fjbh5">Hunter, Jean B.</a></h1><span class="title">Associate Professor, Biological and Environmental Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n7131/thumbnail_datta.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fakd1">Datta, Ashim</a></h1><span class="title">Professor, Biological and Environmental Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n700/thumbnail_lewis.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fmel47">Lewis, Mark E.</a></h1><span class="title">Professor, Operations Research and Information Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n6003/thumbnail_minca.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Facm299">Minca, Andreea C.</a></h1><span class="title">Assistant Professor, Operations Research and Information Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n7467/thumbnail_collins.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Flc2462">Collins, Lance</a></h1><span class="title">Professor, Sibley School of Mechanical and Aerospace Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n8009/thumbnail_trotter.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Flet3">Trotter, Leslie Earl</a></h1><span class="title">Professor, Operations Research and Information Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n1518/thumbnail_pollack.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Flp26">Pollack, Lois</a></h1><span class="title">Professor, Applied and Engineering Physics</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n404/thumbnail_schlom.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fds636">Schlom, Darrell</a></h1><span class="title">Professor, Materials Science and Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n4731/thumbnail_mclask.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fgcm8">McLaskey, Gregory Christofer</a></h1><span class="title">Assistant Professor, Civil and Environmental Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n1279/thumbnail_king.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fmrk93">King, Michael R.</a></h1><span class="title">Professor, Biomedical Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n402/thumbnail_vdm.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fmcv3">van der Meulen, Marjolein</a></h1><span class="title">Professor, Biomedical Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n1355/thumbnail_fischbach.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fcf99">Fischbach, Claudia</a></h1><span class="title">Associate Professor, Biomedical Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n1392/thumbnail_pritch.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fmp337">Pritchard, Matthew</a></h1><span class="title">Associate Professor, Earth and Atmospheric Sciences</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n7712/thumbnail_daniel.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fsd386">Daniel, Susan</a></h1><span class="title">Associate Professor, Chemical and Biomolecular Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n4715/thumbnail_bonnassar.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Flb244">Bonassar, Lawrence</a></h1><span class="title">Professor, Biomedical Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n5537/thumbnail_donnely.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Feld26">Donnelly, Eve Lorraine</a></h1><span class="title">Assistant Professor, Materials Science and Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n686/thumbnail_watson.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fcml66">Watson, Chekesha M.</a></h1><span class="title">Associate Professor, Materials Science and Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n4692/thumbnail_cohen.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fic64">Cohen, Itai</a></h1><span class="title">Associate Professor, Physics</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n6382/thumbnail_jordan.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Ftej1">Jordan, Teresa Eileen</a></h1><span class="title">Professor, Earth and Atmospheric Sciences</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n7756/thumbnail_thomp.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fmot1">Thompson, Michael Olgar</a></h1><span class="title">Associate Professor, Materials Science and Engineering</span>
					</li>
					<li class="individual" style="display:none" role="listitem"><img alt="placeholder image" src="/scholars/file/n5847/thumbnail_estrin.jpg" width="80">
						<h1><a href="/scholars/individual?uri=http%3A%2F%2Fscholars.cornell.edu%2Findividual%2Fde226">Estrin, Deborah</a></h1><span class="title">Professor, Office of the Vice President of Cornell New York City Tech</span>
					</li>
				</ul>

				<script>
				  $(document).ready(function() {
					var fac = $("ul#facultyThumbstest li").get().sort(function() {
						return Math.round(Math.random())-0.5;
					}).slice(0,5);
					$(fac).show();
					$('ul#facultyThumbs').append(fac);
				  });
				</script>


			</div> <!-- body div -->
			<div id="collab_vis" style="z-index:15;border-radius:5px"></div>
			
			<div id="wordcloud_vis" style="z-index:15;border-radius:5px">
      	      <div style="width: 50%; height: 10px; float:left">
                <span class="text-primary" id="content"></span>
              </div>
              <div id="wcUniv">
                <div style="width: 50%; float:right">
                  <div>
                    <span class="glyphicon glyphicon-info-sign pull-right" 
                      data-toggle="tooltip" 
                      data-original-title="The keyword cloud presents the top 300 keywords extracted from the journal articles published by the Cornell faculty and researchers. The size of each keyword in the cloud is directly proportional to the sum of the count of the faculty/researchers. Bigger the keyword in size is, more the faculty members and researcher used the term in their papers.">
                    </span>
                  </div>
                </div>
              </div>
            </div>

			<script>
			$().ready(function() {
			  loadVisualization({
		    	modal : true, 
			    target : '#collab_vis',
			    trigger : '#collaborations_trigger',
			    url : "${urls.base}/api/dataRequest/collaboration_sunburst",
			    transform : transformCollab,
			    display : sunburst,
			    height : 500,
			    width : 700
			  });
			});
			$().ready(function() {
			  loadVisualization({
		    	modal : true, 
			    target : '#wordcloud_vis',
			    trigger : '#wordcloud_trigger',
			    url : "${urls.base}/api/dataRequest/university_word_cloud",
			    transform : transformUniversityWordcloud,
			    display : drawUniversityWordCloud,
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
		<#-- this javascript will clear any "dangling" collaboration tooltips when the modal is closed -->
		<script>
		$().ready(function() {
			$('#collaborations_trigger').click(function() {
					$('div.jqmOverlay').click(function() {
						$('div#tooltip').hide();
						$('div.d3-tip').hide();
					});
			});
		});
		</script>

    </body>
</html>


