<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 collaboration-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Select college and collaboration type
         </h2>
      </div>
      
      <div class="panel-group" id="accordion">
        <div id="collegeSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseColleges">
               participating college
             </a>
          </div>
          <div id="collapseColleges" class="panel-collapse">
            <div class="panel-body" id="selector">
            </div>
          </div>
        </div>
        
        <div id="collabTypes" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTypes">
               collaboration type
             </a>
          </div>
          <div id="collapseTypes" class="panel-collapse">
            <div class="panel-body" id="selector">
            </div>
          </div>
        </div>
      </div> 

      <div id="unit-help-text">
        <font size="2">
          <ul><li id="barchart-disclaimer"  class="barchart-help-text">
            Click on any arc to zoom in and on the center circle to zoom out. 
		    Once zoomed in on a faculty member, click on the outer arc to view a list of co-authored publications.
		  </li></ul>
        </font>
      </div>
    </div>

    <div class="col-md-8">
      <div id="selectedCollaborationLabel"></div>
      
      <#-- 
      =======================================================================
      Collaboration starburst chart - swiped from individual--foaf-organization.ftl
      ======================================================================= 
      -->

	<div id="collab_vis" class="scholars_vis_container dept_collab_vis">
	  <div id="title_bar">
	    <span class="heading"><span id="nowShowing"></span> Co-authorships (Faculty only)</span>
	    <span class="glyphicon glyphicon-info-sign"></span>
	    <a data-view-selector="vis" href="#" style="display: none">Show visualization</a>
	    <a data-view-selector="table" href="#">Show table format</a>
	  </div>
	  
	  <div id="title_bar_info_text">
	    <p>
	      The co-authorships are identified based on the affiliation data 
	      extracted from the citation of a publication. Currently, we only present 
	      co-authorships between researchers with faculty appointments. This visualization 
	      has a zoom-in/zoom-out functionality. The visualization consists of three layers: 
	      unit-level layer (inner most), person-level layer 1 (i.e., author in context) and 
	      the person-level layer 2 (i.e., the co-authors). 
	    </p>
	    <p>
	      To view the co-authorships, begin by selecting  an academic unit of interest. 
	      In this view, you can observe who has co-authored with whom and how often they 
	      co-authored. To view the co-authored publications, begin by selecting a faculty 
	      member of interest. In this view, clicking on a co-author (in the outer circle) 
	      displays the list of co-authored articles in the tooltip. Click in the center 
	      circle to zoom out to select any other faculty/academic unit of interest.
	    </p>
	    <hr> 
	    <p>
	      Note: This information is based solely on publications that have been loaded into the system.
	    </p>
	  </div>
	
	  <div id="time-indicator">
	    <img src="${urls.images}/indicator1.gif"/>
	  </div>
	
	  <div data-view-id="vis">
	    <div id="exports_panel" >
	      <a href="#" data-export-id="json" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Organization', 'Collab-ExportAsJSON']);">Export as JSON</a>
	      <a href="#" data-export-id="svg" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Organization', 'Collab-ExportAsSVG']);">Export as SVG</a>
		</div>
	  </div>
	
	  <div data-view-id="table">
	    <div id="exports_panel">
	      <a href="#" data-export-id="json" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Organization', 'Collab-ExportAsJSON']);">Export as JSON</a>
	      <a href="#" data-export-id="csv" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Organization', 'Collab-ExportAsCSV']);">Export as CSV</a>
	    </div>
	    <table class="vis_table">
	      <thead>
	        <tr>
	          <th data-sort="string-ins">Author</th>
	          <th data-sort="string-ins">Author Affiliation</th>
	          <th data-sort="string-ins">Co-Author</th>
	          <th data-sort="string-ins">Co-Author Affiliation</th>
	          <th data-sort="string-ins">Publication</th>
	          <th data-sort="string-ins">Publication Date</th>
	        </tr>
	      </thead>
	      <tbody>
	        <tr>
	          <td>Template row</td>
	          <td>Template row</td>
	          <td>Template row</td>
	          <td>Template row</td>
	          <td>Template row</td>
	          <td>Template row</td>
	        </tr>
	      </tbody>
	    </table>
	  </div>
	</div>
	
	<!-- End of bar chart visualization -->
	
  </div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/collaborations/collab.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/collaborations/home-collaboration.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis//collaborations/collaborations.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>')}
<script>
$().ready(function() {
    var collegesData = [
        {
            uri: "http://scholars.cornell.edu/individual/org57969",
            label: "College of Agriculture and Life Sciences"
        },
        {
            uri: "http://scholars.cornell.edu/individual/org73341",
            label: "College of Engineering"
        }
    ];
    
    var typesData = [
        {
            label: "Cross-unit Co-authorships"
        },
        {
            label: "Interdepartmental Co-authorships"
        }
    ];
    
    /*
     * - Create the selectors
     */
    var collegeSelector = new AccordionControls.Selector("#collegeSelectionPanel", collegeSelected);
    collegeSelector.loadData(collegesData);
    collegeSelector.expand();
    
    var typeSelector = new AccordionControls.Selector("#collabTypes", typeSelected);
    typeSelector.loadData(typesData);
    typeSelector.expand();
    
    /*
     * Initialize the selections and show the visualization;
     */
    var collabChart = null;
    var selectedCollege;
    var selectedCrossUnit = true;
    $("#collegeSelectionPanel li:first").click();
    $("#collabTypes li:first").click();
    
    function collegeSelected(college) {
      selectedCollege = college;
      showCollaboration();
    }
    
    function typeSelected(type) {
      selectedCrossUnit = (type.label.indexOf("Cross") > -1);
      showCollaboration();
    }
    
    function showCollaboration() {
      if (collabChart != null) {
        collabChart.hide();
      }
      if (selectedCrossUnit) {
        $("#nowShowing").text("Cross-unit");
        collabChart = new ScholarsVis.CollaborationSunburst.FullCrossUnitVisualization({
            target : '#collab_vis',
            department : selectedCollege.uri
        });
      } else {
        $("#nowShowing").text("Interdepartmental");
        collabChart = new ScholarsVis.CollaborationSunburst.FullInterDepartmentVisualization({
            target : '#collab_vis',
            department : selectedCollege.uri
        });
      }
      collabChart.show();
    }
    
    function randomArrayEntry(array) {
        return array[getRandomInt(0, array.length - 1)];
          
        function getRandomInt(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }
    }
});
</script>
