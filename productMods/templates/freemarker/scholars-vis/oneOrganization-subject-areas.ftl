<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="row scholars-row visualization-row">
    
      <div id="organization-subject-areas">
        <div class="vis_toolbar">
          <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
          <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right" style="display: none">Show visualization</a>
          <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
          <span id="selection_text" class="heading">Research areas</span>
        </div>
  
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
  
        <div data-view-id="vis" class="vis-container">
          <div class="vis-exports-container" >
            <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
	      </div>
          <font size="2">
            <span><i>Click on a keyword to view the list of the relevant faculty.</i></span>
          </font>
          <div id="time-indicator">
            <img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
          </div>
        </div>

        <div data-view-id="table" class="vis-table-container">
          <div class="vis-exports-container">
            <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
            <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
          </div>
          <table class="scholars-vis-table">
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

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
				  '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis-2.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/FileSaver.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/stupidtable.min.js"></script>'
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>')}


<script>
$().ready(function() {
  /*
   * What is the right place to do these things?
   * - Is this really the best place for a very useful function like getParameterByName() ?
   */
  var deptUri = getParameterByName("deptURI", window.location.http);
  var deptLabel = getParameterByName("deptLabel", window.location.http);
  $("#selection_text").html("Research areas for <a href=\"" + toDisplayPageUrl(deptUri) + "\">" + deptLabel + "</a>");

  function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
    var results = regex.exec(url);
    if (!results) return '';
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }
  
  var ora = new ScholarsVis2.OrganizationResearchAreas({
    target : '#organization-subject-areas',
    organization : deptUri
    });
  ora.show();
  
  ora.examineData(function(flaredata) {
    console.log("FLARE DATA\n" +flaredata);
    if (!flaredata || !flaredata.ditems || flaredata.ditems.length == 0) {
        ora.showView("empty");
    }
  });
  
    
});
</script>
