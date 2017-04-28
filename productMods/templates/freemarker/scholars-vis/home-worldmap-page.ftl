<div id="worldMapContainer" class="col-md-12 scholars-container">
		<div class="row" id="mapRow">
			<div class="col-md-4">
				<div>
         			<h2 style="padding:0;color:#5f5858;font-size:20px">
            			Browse global collaborations
         			</h2>
         			<p style="font-size:12px">
         				Filter data by selecting an academic unit, subject area or publication year(s).
         			</p>
      			</div>

				<div class="panel-group" id="accordion">
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
									<span class="start">Filter by:</span> Academic Unit
								</a>
							</h4>
						</div>
						<div id="collapseOne" class="panel-collapse collapse">
							<div class="panel-body" id="academicUnit">
								<input type="text" class="form-control" id="academicInput" placeholder="Search">
							</div>
						</div>
					</div>
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
									<span class="start">Filter by:</span> Subject Area
								</a>
							</h4>
						</div>
						<div id="collapseTwo" class="panel-collapse collapse">
							<div class="panel-body" id="subjectArea">
								<input type="text" class="form-control" id="subjectInput" placeholder="Search">
							</div>
						</div>
					</div>

					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseThree">
									<span class="start">Filter by:</span> Publication Year
								</a>
							</h4>
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
			</div>
			<div class="col-md-8 container">
			<div id="mapViz">
				<div id="info_icon_text" style="display:none">
          			This global collaborations.
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
					<span id="hamburgerIcon" class="glyphicon glyphicon-menu-hamburger"></span>
					<h3 id="areaTitle"></h3>
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

	</div>

	${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/world-map-collab/styles.css"/>', '<link rel="stylesheet" href="${urls.base}/css/scholars-vis/world-map-collab/nouislider.min.css"/>')}


	${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/topojson.v1.min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/underscore-min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/d3-queue.v3.min.js"></script>', 
	'<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/university-world-map.js"></script>', 
	'script', 
	'<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
	'<script src="${urls.base}/js/scholars-vis/grants/nouislider.min.js"></script>')}
	
	<script type="text/javascript">
		$().ready(function() {
			// new ScholarsVis.GlobalCollaboration({
			// target: "#mapViz"
			// }).show();
			initializeMap();
			
		});
		$().ready(function() {
  			new ScholarsVis.Toolbar("#mapVis");
		});
	</script>
