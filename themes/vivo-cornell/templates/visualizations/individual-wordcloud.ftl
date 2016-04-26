 <style>
 /* http://nicolasgallagher.com/pure-css-speech-bubbles/demo/default.css */
 .choices {
    background-color: rgba(50, 50, 50, 0.8);
    color: #DDDDDD;
    font-family: Arial;
    cursor: pointer;
 }
 .triangle-isosceles {
  position:relative;
  padding:15px;
  margin:1em 0 3em;
  -webkit-border-radius:10px;
  -moz-border-radius:10px;
  border-radius:10px;
}
 .hoverable {
    width:100%;
    padding:5px;
 }
 .hoverable a {
    color:white;
    text-decoration: none;
 }
 .hoverable:hover {
    background-color:rgba(50, 150, 200, 0.8);
 }
 </style>
 
<div id="person_word_cloud"></div>

<a href="#" id="word_cloud_trigger">WordCloud</a>

${stylesheets.add('<link rel="stylesheet" href="${urls.theme}/css/visualizations/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/popup-rdf.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/person-word-cloud.js"></script>')}

<script>
$().ready(function() {
  popupRdf({
    target : '#person_word_cloud',
    trigger : '#word_cloud_trigger',
    url : "${urls.base}/api/distributeRdf?action=person_word_cloud&person=${individual.uri?url}",
    transform : transform_word_cloud_data,
    display : draw_word_cloud
  });
});
</script>
