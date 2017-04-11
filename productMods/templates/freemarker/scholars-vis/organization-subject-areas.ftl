<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 kwcloud-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research keywords
         </h2>
         <p style="font-size:12px">Select an academic department.</p>
      </div>
      
      <div class="panel-group" id="accordion">

        <div id="departmentSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                <span class="start">Select:</span> Academic Department
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

      <div>
        <font face="Times New Roman" size="2">
          <span><i>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
            Cras finibus blandit turpis, eu egestas est sagittis eget. 
            Duis eu enim. 
          </i></span>
        </font>
      </div>

    </div>

    <div class="col-md-8">
	  <div id="organization-subject-areas" style="padding-bottom:60px;height:500px;width:100%">
	    <div id="info_icon_text" style="display:none">
		  Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
		  Cras finibus blandit turpis, eu egestas est sagittis eget. 
		  Duis eu enim. 
		</div>
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
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/svg-pan-zoom.js"></script>',
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
   *
   */
  new ScholarsVis.Toolbar("#organization-subject-areas");

  var departmentControl = new AccordionControls.Selector("#departmentSelectionPanel", showDepartmentCloud);
  departmentControl.loadFromDataRequest("departmentList");

  var requestingDept = getParameterByName("deptURI", window.location.http);
  if (requestingDept.length > 0) {
    showDepartmentCloud({uri: requestingDept});
  }
  
  var ora = null;
    
  function showDepartmentCloud(dept) {
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
});
</script>
