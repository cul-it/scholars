/*
 * Include this script to embed the Word Cloud visualization for the University. 
 */
ScholarsVis.Utilities.loadScripts(
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/wordcloud/university-word-cloud.js",
        ScholarsVis.Utilities.baseUrl + "js/d3.min.js",
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/d3/d3-tip.js",
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/d3/d3.layout.cloud.js"
        );

ScholarsVis.Utilities.loadStyles(
        ScholarsVis.Utilities.baseUrl + "css/scholars-vis/keywordcloud/site-kwcloud.css"
        );
