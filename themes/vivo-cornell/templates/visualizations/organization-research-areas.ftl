<div id="organization-research-areas">
<div>

<script>
$().ready(function() {
  loadVisualization({
    target : '#organization-research-areas',
    url : "${urls.base}/api/dataRequest?action=organization_research_areas&organization=${individual.uri?url}",
    parse : 'turtle',
    transform : transformFlaredata,
    display : plotConceptMap,
    height : 0.75,
    width : 0.75
  });
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.theme}/css/visualizations/cbe-ra.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/organization-research-areas.js"></script>')}
