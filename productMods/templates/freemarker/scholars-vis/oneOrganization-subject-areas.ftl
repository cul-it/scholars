<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="row scholars-row visualization-row">
	  <div id="organization-subject-areas" style="padding-bottom:60px;width:100%">
 			<div id="time-indicator">
 			    <img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
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
			<div id="selection_text"></div>
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
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>')}

<script>
$().ready(function() {
  /*
   * What is the right place to do these things?
   * - Is this really the best place for a very useful function like getParameterByName() ?
   */
  var toolbar = new ScholarsVis.Toolbar("#organization-subject-areas");

  var deptUri = getParameterByName("deptURI", window.location.http);
  var deptLabel = getParameterByName("deptLabel", window.location.http);
  toolbar.setHeadingText("Research areas for <a href=\"" + toDisplayPageUrl(deptUri) + "\">" + deptLabel + "</a>");
  new ScholarsVis.OrganizationResearchAreas({
    target : '#organization-subject-areas',
    organization : deptUri
    }).show();

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
