<div class="row scholars-row">
  <div id="grants-vis-container" class="col-md-12 scholars-container" style="min-height: 700px">

    <div id="time-indicator">
      <img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
    </div>

    <div data-view-id="vis" class="vis-container">
    <div class="col-md-4" class="scholars-container">
     
      <div>
         <h2 style="padding:0 0 20px 0;color:#5f5858;font-size:20px">
            Browse research grants
         </h2>
      </div>

      <div class="panel-group" id="accordion">
        
        <div id="personSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapsePerson">
                Investigator
              </a>
          </div>
          <div id="collapsePerson" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div id="unitSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseUnit">
                Academic Unit
              </a>
          </div>
          <div id="collapseUnit" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div id="agencySelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseAgency">
                Funding Agency
              </a>
          </div>
          <div id="collapseAgency" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>

        <div id="dateRangePanel" class="panel panel-default">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Filter by:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseDate">
                Active Year
              </a>
          </div>
          <div id="collapseDate" class="panel-collapse collapse">
            <div class="panel-body" id="date">
              <div id="slider"></div>
            </div>
          </div>
        </div>
      
        <div>
          <h5><a id="resetLink">Reset</a></h5>
        </div>

        <div>
          <font size="2">
            <span><i>Hover over grant bubbles to browse the titles of the grants. 
            Click on a bubble to view the details of the funded grant.</i></span>
          </font><br>
        </div>

      </div> 

      <div id="grantsLegendDiv" class="center-block"> </div>
    </div>
    
    <div class="col-md-8" id="vis_holder">
        <div id="info_icon_text" style="display:none"> 
          <p>
            This visualization represents a bird's eye view of all the grants where 
            a Cornell faculty member or a researcher is either a Principal or 
            Co-Principal Investigator. The data is represented as a cluster of 
            bubbles where each bubble represents a grant and the size of the bubble 
            indicates the relative award amount. The color scheme in the lower left 
            of the page reveals the dollar amount range of the grant. This provides 
            a quick visual view of the active research grants for the entire university. 
          </p>
          <p>
            While the visualization starts from a big cluster, one can scale the 
            view by selecting a funding agency, academic unit, active year range or 
            faculty member of interest. Clicking on a grant bubble displays the full 
            description of the grant, including the title, the list of investigators, 
            and other information.
          </p>
          <hr> 
          <p>
            Note: This information is based solely on grants that have been loaded 
            into the system through OSP (Office of Sponsored Program) feed.
          </p> 
        </div>
        <div class="vis_toolbar">
          <span class="heading">0 grants</span>
          <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
          <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
        </div>

    <div class="vis-exports-container" >
      <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
	</div>
      
        <div id="grants_vis" style="width:600px; height:600px"> </div>
    </div>
    </div>
    <div data-view-id="table" class="vis-table-container">
      <div class="vis_toolbar">
          <span class="heading">All grants</span>
          <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
          <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right">Show visualization</a>
      </div>
    <div class="vis-exports-container">
      <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
    </div>
    <table class="scholars-vis-table" style="height:600px">
      <thead>
        <tr>
          <th data-sort="string-ins">Type</th>
          <th data-sort="string-ins">Grant</th>
          <th data-sort="string-ins">Department</th>
          <th data-sort="string-ins">FundingAgency</th>
          <th data-sort="string-ins">Start Year</th>
          <th data-sort="string-ins">End Year</th>
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
</div>
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/grants/nouislider.min.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/grants/bubble_chart.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css">')}
${stylesheets.add('<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis-2.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/stupidtable.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/FileSaver.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/transform-data.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/grants_tooltip.js"></script>',
              '<script type="text/javascript" src="https://d3js.org/d3.v3.min.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/nouislider.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>',
              '<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.16.6/lodash.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/grants/bubble_chart_script.js"></script>'
              )}

<script type="text/javascript">
    $(document).ready(function() {
        var gv = new ScholarsVis2.SiteGrants({
		    target : '#grants-vis-container',
		    mainDiv : '#grants_vis', 
		    legendDiv : '#grantsLegendDiv',
		    personFilter: "#personSelectionPanel",
		    unitFilter: "#unitSelectionPanel",
		    agencyFilter: "#agencySelectionPanel",
		    dateRangePanel: "#dateRangePanel",
		    resetLink: "#resetLink"
		});
		gv.show();
    });
</script>
