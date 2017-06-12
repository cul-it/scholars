<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="row scholars-row visualization-row">
    <div class="col-md-4 kwcloud-selector">

            <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research interests
         </h2>
         <p style="font-size:12px">Select an academic unit.</p>
      </div>
      
      <div class="panel-group" id="accordion">

        <div id="departmentSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                <span class="start">Select:</span> Academic Unit
              </a>
            </h4>
          </div>
          <div id="collapseOne" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>
                
      </div> 
    </div> 

    <!--
    <div class="col-md-8 kwcloud-selector">
      <div>
        <font face="Times New Roman" size="2">
          <span><i>
            Hover over a faculty's name to see one's research interests.  
          </i></span>
        </font>
      </div>
    </div>
    -->
    </div>
  <div class="row scholars-row visualization-row">
  <div class="col-md-12">
	  <div id="organization-subject-areas" style="padding-bottom:60px;width:100%">
		    <div id="info_icon_text" style="display:none">
		      <p>
			  This visualization represents all the faculty in the selected organizational unit 
			  linked to all the subject areas in which faculty have published in. Subject areas 
			  are derived from the subject area classification of the journals assigned by the 
			  publishers. We infer that any article that is published in a particular journal 
			  has the subject area classification of that journal. Thus, the author of such 
			  article is said to have research interest in those subject areas. 
			  </p>
			  <p>
			  This visualization
			  can be looked in two ways. One is by hovering over the author names (given in the 
			  center), in which case, the links to the subject areas will be highlighted. 
			  Alternatively, by hovering over a subject area, will highlight all the authors 
			  who have published in that subject area.
			  </p> 
			  <hr> 
			  <p>
			  Note: This information is based solely on publications that have been loaded 
			  into the system.
			  </p> 
			</div>
			<div id="selection_text"></div>
	  </div>
  </div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
				  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>')}

<script>
$().ready(function() {
  /*
   * What is the right place to do these things?
   * - Create the selector and populate it
   * - If a 'deptURI' is present in the URL that got us here, show that department.
   *   - Should this even remain? Since this should probably appear as a modal on the department page
   * - Is this really the best place for a very useful function like getParameterByName() ?
   */
  var toolbar = new ScholarsVis.Toolbar("#organization-subject-areas");

  var departmentControl = new AccordionControls.Selector("#departmentSelectionPanel", showDepartmentCloud);
  departmentControl.loadFromDataRequest("departmentList");

  showFeaturedDepartment();
  
  var ora = null;
    
  function showDepartmentCloud(dept) {
    departmentControl.collapse();
    toolbar.setHeadingText("Research areas for <a href=\"" + toDisplayPageUrl(dept.uri) + "\">" + dept.label + "</a>");
    if (ora != null) {
      ora.hide();
    }
    ora = new ScholarsVis.OrganizationResearchAreas({
	             target : '#organization-subject-areas',
	      		 organization : dept.uri
				 });
	ora.show();
  }

  function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
    var results = regex.exec(url);
    if (!results) return '';
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }
  
  /*
   * Start by displaying one of our featured departments. 
   */
  function showFeaturedDepartment() {
    // This array should contain uris and labels for all of the featured departments.
    var featuredDepartments = [
      {
        uri: "http://scholars.cornell.edu/individual/org68763",
        label: "Meinig School of Biomedical Engineering"
      },
      {
        uri: "http://scholars.cornell.edu/individual/org80541",
        label: "Smith School of Chemical and Biomolecular Engineering"
      }
    ];
   
    showDepartmentCloud(randomArrayEntry(featuredDepartments));

    function randomArrayEntry(array) {
      return array[getRandomInt(0, array.length - 1)];
    
      function getRandomInt(min, max) {
       return Math.floor(Math.random() * (max - min + 1)) + min;
      }
    }
  }
});
</script>
