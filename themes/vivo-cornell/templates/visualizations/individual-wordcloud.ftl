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

<div id="person_word_cloud"><h1>URI: ${individual.uri}</h1></div>

<script>
word_cloud_data_uri = "${urls.base}/mls50.csv"
</script>

${scripts.add('<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.min.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3.layout.cloud.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/d3-tip.js"></script>',
              '<script type="text/javascript" src="${urls.theme}/js/visualizations/person-word-cloud.js"></script>')}
