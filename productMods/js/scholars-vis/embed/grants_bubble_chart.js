/*
 * DEPRECATED - This script will be removed in a future release of Scholars.
 *
 * For updated instructions on how to embed the Grants Bubble Chart visualization, 
 * consult the notes and examples here:
 * https://github.com/cul-it/scholars/tree/develop/doc/visualizations/embedding_in_other_sites/grants_bubble_chart
 *
 */
ScholarsVis.Utilities.loadScripts(
        ScholarsVis.Utilities.baseUrl + "js/d3.min.js",
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/grants/transform-data.js",
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/grants/grants_tooltip.js",
        ScholarsVis.Utilities.baseUrl + "js/scholars-vis/grants/bubble_chart_script.js"
        );

ScholarsVis.Utilities.loadStyles(
        ScholarsVis.Utilities.baseUrl + "css/scholars-vis/grants/bubble_chart.css"
        );
