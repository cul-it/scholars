<h1>Worldmap Visualization</h1>

<div id="worldMapContainer"></div>


${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/worldmap/university-world-map.js"></script>')}

<script type="text/javascript">
  $().ready(function() {
  	displayWorldMap($("#worldMapContainer"));
  });
</script>
