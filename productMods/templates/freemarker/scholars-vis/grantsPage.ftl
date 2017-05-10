<div class="row scholars-row">
  <div id="grants-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4" class="scholars-container">
     
      <div>
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research grants
         </h2>
         <p style="font-size:12px">Filter grants by selecting an investigator, academic unit, funding agency or active year(s).</p>
      </div>

      <div class="panel-group" id="accordion">
        
        <div id="personChecklistPanel" class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapsePerson">
                <span class="start">Filter by:</span> Investigator
              </a>
            </h4>
          </div>
          <div id="collapsePerson" class="panel-collapse collapse">
            <div id="checkarea" class="panel-body">
              <input type="text" class="form-control" id="listFilter" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div id="unitChecklistPanel" class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseUnit">
                <span class="start">Filter by:</span> Academic Unit
              </a>
            </h4>
          </div>
          <div id="collapseUnit" class="panel-collapse collapse">
            <div id="checkarea" class="panel-body">
              <input type="text" class="form-control" id="listFilter" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div id="agencyChecklistPanel" class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseAgency">
                <span class="start">Filter by:</span> Funding Agency
              </a>
            </h4>
          </div>
          <div id="collapseAgency" class="panel-collapse collapse">
            <div id="checkarea" class="panel-body">
              <input type="text" class="form-control" id="listFilter" placeholder="Search"/>
            </div>
          </div>
        </div>
        
        <div id="dateRangePanel" class="panel panel-default">
          <div class="panel-heading">
            <h4 class="panel-title">
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseDate">
                <span class="start">Filter by:</span> Active Year
              </a>
            </h4>
          </div>
          <div id="collapseDate" class="panel-collapse collapse">
            <div class="panel-body" id="date">
              <div id="slider"></div>
            </div>
          </div>
        </div>
      
        <div>
          <h5><a id="checkAllLink">Check All</a> | <a id="uncheckAllLink">Uncheck All</a></h5>
        </div>

        <div>
          <font face="Times New Roman" size="2">
            <span><i>Hover over grant bubbles to browse the titles of the grants. Click on a grant's bubble to view the details of a funded grant.</i></span>
          </font><br>
        </div>

      </div> 

      <div id="grantsLegendDiv" class="center-block"> </div>
    </div>
    
    <div class="col-md-8" id="vis_holder">
        <div id="info_icon_text" style="display:none"> 
          <p>
            This visualization represents a bird-view of all the grants where a Cornell faculty member or a researcher is either a Principal or Co-Principal Investigator. The data is represented as a cluster of bubbles where each bubble represents a grant and the size of the bubble indicates the relative award amount. The color scheme in lower left of the page reveals the dollar amount range of the grant. This provides a quick visual view of the active research grants for the entire university. 
          </p>
          <p>
            While the visualization starts from a big cluster, one can narrow down the view by selecting the funding agency, academic unit, active year range or the faculty member of interest. Clicking on a grant bubble will display the full description of the grant including title, list of investigators and other information.
          </p>
          <hr> 
          <p>
            Note: This information is based solely on grants that have been loaded into the system through OSP (Office of Sponsored Program) feed.
          </p> 
        </div>
      <div id="grants_vis" style="width:600px; height:600px"> </div>
    </div>
  </div>
</div>
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/grants/nouislider.min.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/grants/bubble_chart.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/transform-data.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/grants_tooltip.js"></script>',
              '<script type="text/javascript" src="https://code.jquery.com/jquery-3.1.1.min.js"   integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="   crossorigin="anonymous"></script>',
              '<script type="text/javascript" src="https://d3js.org/d3.v3.min.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/nouislider.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>',
              '<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.16.6/lodash.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/bubble_chart_script.js"></script>'
              )}

<script type="text/javascript">
    $(document).ready(function() {
		new ScholarsVis.SiteGrants({
		    target : '#grants_vis',
		    legendDiv : '#grantsLegendDiv',
		    personChecklistPanel: "#personChecklistPanel",
		    unitChecklistPanel: "#unitChecklistPanel",
		    agencyChecklistPanel: "#agencyChecklistPanel",
		    dateRangePanel: "#dateRangePanel",
		    checkAllLink: "#checkAllLink",
		    uncheckAllLink: "#uncheckAllLink"
		}).show();

        new ScholarsVis.Toolbar("#vis_holder");
    });
</script>
