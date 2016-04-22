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
 
<div id="person_word_cloud" class="jqmWindow"><span>THIS IS IT?</span></div>

<a href="#" class="jqModal" id="word_cloud_trigger">WordCloud</a>

<script>

$().ready(function() {
  word_cloud_data_uri = "${urls.base}/api/distributeRdf?action=person_word_cloud&person=${individual.uri?url}"
  
  $('#person_word_cloud').jqm({
    trigger:'#word_cloud_trigger',
    onShow: function(hash) {
      $.get(word_cloud_data_uri, function(turtle) {
        hash.o.prependTo('body');
        createPersonWordCloud(turtle, "#person_word_cloud");
        hash.w.fadeIn();
      }) 
    } 
  }); 
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.theme}/css/visualizations/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/jqModal.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/rdflib.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/person-word-cloud.js"></script>')}
