<H1>COLLABORATIONS</H1>

<div id="collab_vis"></div>

<script>
$().ready(function() {
  loadVisualization({
    target : '#collab_vis',
    url : "${urls.base}/api/dataRequest?action=collaboration_sunburst",
//    transform : fake_data,
    display : sunburst,
    height : 500,
    width : 700
  });
});
</script>

<link rel="stylesheet" href="${urls.base}/css/scholars-vis/collaborations/collab.css" />

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/collaborations/collaborations.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>')}

