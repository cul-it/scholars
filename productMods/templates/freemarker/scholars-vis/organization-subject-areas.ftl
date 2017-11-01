<div class="row scholars-row">
	<div id="wc-vis-container" class="col-md-12 scholars-container">
		<div class="row"  style="background-color:#fff;margin:0;padding:0;">
	    	<div class="col-md-4 kwcloud-selector">
	        	<div id="legendDiv" class="center-block">
	         		<h2 style="padding:0 0 20px 0;color:#5f5858;font-size:20px">
	            		Browse research interests
	         		</h2>
	      		</div>
	      		<div class="panel-group" id="accordion">
	        		<div id="departmentSelectionPanel" class="panel panel-default selection-list">
	          			<div class="panel-heading facet-panel-heading panel-title">
	            			<span class="start">Select:</span> 
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
	              				Academic Unit
	            			</a>
	          			</div>
	          			<div id="collapseOne" class="panel-collapse collapse">
	            			<div class="panel-body" id="selector">
	              				<input id="searcher" type="text" class="form-control" placeholder="Search"/>
	            			</div>
	          			</div>
					</div>
	        	</div>    
	      	</div> 
    	</div>
  		<div class="row visualization-row">
  			<div class="col-md-12">
  			
      <div id="organization-subject-areas" class="scholars_vis_container">
        <div id="title_bar">
          <span class="glyphicon glyphicon-info-sign"></span>
          <a data-view-selector="vis" href="#" style="display: none">Show visualization</a>
          <a data-view-selector="table" href="#">Show table format</a>
          <span id="selection_text" class="heading">Research areas</span>
        </div>
  
	    <div id="title_bar_info_text" style="display:none">
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
  
        <div id="time-indicator">
          <img src="${urls.images}/indicator1.gif"/>
        </div>

        <div data-view-id="vis">
          <div id="exports_panel" >
            <a href="#" data-export-id="json">Export as JSON</a>
	      </div>
          <font size="2">
            <span><i>Click on a keyword to view the list of the relevant faculty.</i></span>
          </font>
        </div>

        <div data-view-id="table">
          <div id="exports_panel">
            <a href="#" data-export-id="json">Export as JSON</a>
            <a href="#" data-export-id="csv">Export as CSV</a>
          </div>
          <table class="vis_table">
            <thead>
              <tr>
                <th data-sort="string-ins">Faculty Member</th>
                <th data-sort="string-ins">Subject Area</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Template row</td>
                <td>Template row</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div data-view-id="empty">
          <div style="text-align: center;">
            <img src="${urls.base}/themes/scholars/images/person_sa_noData.png"/>
          </div>
        </div>

	  </div>
			</div>
		</div>
	</div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>')}

<script>
$().ready(function() {
    /*
     * What is the right place to do these things?
     * - Create the selector and populate it
     * - Show a featured department
     * - Because 'ora' is global to showDepartmentCloud(), the ora.hide() functionality is brittle. How to do it correctly?
     */
    var departmentControl = new AccordionControls.Selector("#departmentSelectionPanel", showDepartmentCloud);
    departmentControl.loadFromDataRequest("departmentList");
    
    var ora = null;
    showFeaturedDepartment();
    
    function showDepartmentCloud(dept) {
        departmentControl.collapse();
        $("#selection_text").html("Research areas for <a href=\"" + ScholarsVis.Utilities.toDisplayUrl(dept.uri) + "\">" + dept.label + "</a>");
        if (ora != null) {
            ora.hide();
        }
        ora = new ScholarsVis.OrganizationResearchAreas({
            target : '#organization-subject-areas',
            organization : dept.uri
        });
        ora.show();
        ora.examineData(function(flaredata) {
            if (!flaredata || !flaredata.ditems || flaredata.ditems.length == 0) {
                ora.showView("empty");
            }
        });
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
