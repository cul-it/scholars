
<div id="bubbleChart_area" class="bubbleChart2"></div>

<script>
$().ready(function() {
  loadVisualization({
    target : '#bubbleChart_area',
    url : "${urls.base}/api/dataRequest?action=research_area_bubbles",
    transform : transform_bubble_chart_data,
    display : draw_bubble_chart,
    height : 500,
    width : 500
  });
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/research-areas/ra.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-transform.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/misc.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/micro-observer.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/microplugin.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/bubble-chart.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/central-click.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/lines.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/research-areas-bubble-chart.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/research-areas/ext-array.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>')}
