<div class="row scholars-row" id="mapRow">
    <div id="worldMapContainer" class="col-md-12 scholars-container" style="min-height: 600px">

        <div id="time-indicator">
            <img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
        </div>

        <div id="info_icon_text" style="display:none">
            <p>
                This visualization presents the national and the international level co-authorships of Cornell faculty and researchers. The global co-authorships were identified from the affiliation data attached to the citation of a publication. While the visualization starts with co-authorships for all the Cornell academic units, one can filter the data by selecting either a specific academic unit, subject area or the publication year range. 
            </p>
            <p>
                Clicking on a country (in the country map) or a state (in the USA map) opens a side panel presenting the featured Cornell faculty/researchers and the featured institutions from the selected country/state. The color scheme in left panel of the page reveals the range of the co-authorship counts.  
            </p>
            <hr> 
            <p>
                Note: This information is based solely on publications that have been loaded into the system.
            </p> 
        </div>

        <div data-view-id="vis" class="vis-container">
            <div class="col-md-4">
                <div style="padding:0 0 20px 0">
                    <h2 style="color:#5f5858;font-size:20px">
                        Browse global collaborations
                    </h2>
                    <font size="2"><span><i>(2012 - 2017)</i></span></font>
                </div>

                <div class="panel-group" id="accordion">
                    <div class="panel panel-default">
                        <div class="panel-heading panel-title facet-panel-heading">
                            <span class="start">Filter by:</span>
                            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                                Academic Unit
                            </a>
                        </div>
                        <div id="collapseOne" class="panel-collapse collapse">
                            <div class="panel-body" id="academicUnit">
                                <input type="text" class="form-control" id="academicInput" placeholder="Search">
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading panel-title facet-panel-heading">
                            <span class="start">Filter by:</span>
                            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
                                Subject Area
                            </a>
                        </div>
                        <div id="collapseTwo" class="panel-collapse collapse">
                            <div class="panel-body" id="subjectArea">
                                <input type="text" class="form-control" id="subjectInput" placeholder="Search">
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading panel-title facet-panel-heading">
                            <span class="start">Filter by:</span>
                            <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
                                Publication Year
                            </a>
                        </div>
                        <div id="collapseThree" class="panel-collapse collapse">
                            <div class="panel-body" id="date">
                                <div id="range"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <a id="clear">Clear Filter</a>
                <div id="legendDiv">
                </div>
            </div> <!-- col-md-4 -->

            <div class="col-md-8 container">
                <div id="mapViz">
                    <div class="vis_toolbar">
                        <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
                        <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
                        <span class="heading">Global Collaborations</span>
                    </div>

                    <div class="vis-exports-container">
                        <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
                        <a href="javascript:return false;" data-export-id="svg" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as SVG</a>
                    </div>

                    <h5 class="normal"> Now Showing: <span id="nowShowing">All</span></h5>

                    <form class="form-inline">
                        <label class="radio-inline"><input type="radio" name="map" value="world" checked>World Map</label>
                        <label class="radio-inline" id="usa-label"><input type="radio" name="map" value="usa">USA Map</label>
                    </form>

                </div>
            </div>

            <div class="closed" id="rh-panel">
                <div id="inner">
                    <div class="row topRow">
                        <h3 id="areaTitle"></h3>
                        <span id="hamburgerIcon" class="glyphicon glyphicon-remove-circle pull-right"></span>
                    </div>
                    <br>
                    <h4 class="heading-travis" id="res"></h4>
                    <div id="researchers1" class="list scroll1">
                    </div>
                    <br>
                    <h4 class="heading-travis" id="inst"></h4>
                    <div id="institutions" class="list scroll1">
                    </div>
                </div>
            </div>
        </div> <!-- data-view-id="vis" -->

        <div data-view-id="table" class="vis-container">
            <div class="col-md-12">

                <div class="vis_toolbar">
                    <span class="heading">Global Collaborations</span>
                    <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
                    <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right">Show visualization</a>
                </div>
                
                <div class="vis-exports-container">
                    <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
                    <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
                </div>

                <form class="form-inline">
                    <label class="radio-inline"><input type="radio" name="map" value="world" checked>World Map</label>
                    <label class="radio-inline" id="usa-label"><input type="radio" name="map" value="usa">USA Map</label>
                </form>
                
                <table id="world-table" class="scholars-vis-table" style="height:600px; width:fit-content">
                    <thead>
                        <tr>
                            <th data-sort="string-ins">Country</th>
                            <th data-sort="int">Publication Count</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Template row</td>
                            <td>Template row</td>
                        </tr>
                    </tbody>
                </table>
                
                <table id="country-table" class="scholars-vis-table" style="height:600px; width:fit-content">
                    <thead>
                        <tr>
                            <th data-sort="string-ins">State</th>
                            <th data-sort="int">Publication Count</th>
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
        </div> <!-- data-view-id="table" -->
    </div>
</div>

	${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/world-map-collab/styles.css"/>', '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/world-map-collab/nouislider.min.css"/>')}


	${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/topojson.v1.min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/underscore-min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/d3-queue.v3.min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/university-world-map.js"></script>',
	'<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
	'<script src="${urls.base}/js/scholars-vis/grants/nouislider.min.js"></script>')}
	<script>
		var urlsBase = "${urls.base}";
	</script>
	<script type="text/javascript">
		$().ready(function() {
			new ScholarsVis.GlobalCollaboration({
			  target: "#worldMapContainer"
			}).show();
		});
	</script>
