 
<div id="person_word_cloud" style="z-index: 3"></div>

<a href="#" id="word_cloud_trigger">WordCloud</a>

<script>
$().ready(function() {
  loadVisualization({
    modal : true, 
    target : '#person_word_cloud',
    trigger : '#word_cloud_trigger',
    url : "${urls.base}/api/dataRequest/person_word_cloud?person=${individual.uri?url}",
    parse : 'turtle',
    transform : transform_word_cloud_data,
    display : draw_word_cloud,
    height : 0.75,
    width : 0.75
  });
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}
${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/kwcloud.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/visualization-loader.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/person-word-cloud.js"></script>')}
