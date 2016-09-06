<div id="bubbleChart_area" style="height:500px;width:500px;"></div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/research-areas/ra.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-transform.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/misc.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/micro-observer.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/microplugin.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/bubble-chart.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/central-click.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/lines.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/research-areas-bubble-chart.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/ext-array.js"></script>')}

<script>
$().ready(function() {
  new ScholarsVis.ResearchAreasBubbleChart({
	target : '#bubbleChart_area'
  }).show();
});
</script>