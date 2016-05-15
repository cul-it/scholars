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

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/org-research-areas/ra.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/org-research-areas/organization-research-areas.js"></script>')}
