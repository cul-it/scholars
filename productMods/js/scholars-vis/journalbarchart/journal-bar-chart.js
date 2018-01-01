var BarChartVis = (function() {
    return {
        transformdata: transformdata,
        display: display,
        close: close,
        exportVisAsJson: exportVisAsJson,
        exportVisAsSvg: exportVisAsSvg,
        exportTableAsCsv: exportTableAsCsv,
        exportTableAsJson: exportTableAsJson
    };
    
    /*
     * Get: a sorted array of academic units, a sorted list of years, a double
     * map of the articles, indexed by unit and year, a two-dimensional array of
     * "column data", for the graph.
     */
    function transformdata(rawData, options) {
        var bindings = rawData.results.bindings;
        var units = enumerateUnits();
        var years = enumerateYears();
        var articlesMap = fillArticlesMap(createArticlesMap());
        var columnData = buildColumnData();
        
        return {
            units: units,
            years: years,
            articles: articlesMap,
            columnData: columnData
        }

        function enumerateUnits() {
            var set = new Set();
            for (var i = 0; i < bindings.length; i++) {
                set.add(bindings[i].unitName.value);
            }
            return Array.from(set).sort();
        }
        
        function enumerateYears() {
            var lowest = 9999;
            var highest = 0;
            for (var i = 0; i < bindings.length; i++) {
                var year = parseInt(bindings[i].date.value.substring(0, 4));
                if (year <  lowest) lowest = year;
                if (year >  highest) highest = year;
            }
            var years = [];
            for (var y = lowest; y <= highest; y++) {
                years.push("" + y);
            }
            return years;
        }
        
        function createArticlesMap() {
            var outer = {};
            for (var u = 0; u < units.length; u++) {
                var inner = {};
                for (var y = 0; y < years.length; y++) {
                    inner[years[y]] = {};
                }
                outer[units[u]] = inner;
            }
            return outer;
        }
        
        function fillArticlesMap(map) {
            console.log("years: " + JSON.stringify(years, null, 2));
            console.log("map: " + JSON.stringify(map, null, 2));
            bindings.forEach(processBinding);
            return map;
            
            function processBinding(binding) {
                var unit = binding.unitName.value;
                var year = binding.date.value.substring(0, 4);
                var articleUri = binding.article.value;
                var articleTitle = binding.title.value;
                console.log("unit: " + unit);
                console.log("year: " + year);
                map[unit][year][articleUri] = articleTitle;
            } 
        }
        
        function buildColumnData() {
            var columns = [];
            for (var u = 0; u < units.length; u++) {
                var unit = units[u];
                var column = [unit];
                for (var y = 0; y < years.length; y++) {
                    var year = years[y];
                    column.push(Object.keys(articlesMap[unit][year]).length); 
                }
                columns.push(column);
            }
            return columns;
        }
    }
    
    function display(data, target) {
        console.log("DISPLAY_DATA: " + JSON.stringify(data, null, 2));
        var chart = c3.generate({
            bindto: target,
            data: {
                columns: data.columnData,
                type: 'bar',
                groups: [data.units],
                onclick: function (d, element) {
                    addPanel();
                    console.log(element);
                    console.log(d);
                }
            },
            legend: {
                position: 'right'
            },
            axis: {
                y: {
                    label: 'Publication Count'
                },
                x: {
                    label: {
                        text: 'Publication Year',
                        position: 'outer-right'
                    },
                    tick: {
                        rotate: 0 
                    },
                    type: 'category',
                    categories: data.years
                }},
                tooltip: {
                    grouped: false // Default true
                }
        });
    }
    
    function close() {
        console.log("BOGUS BarChartVis.close");
    }
    
    function exportVisAsJson() {
        console.log("BOGUS BarChartVis.exportVisAsJson");
    }
    
    function exportVisAsSvg() {
        console.log("BOGUS BarChartVis.exportVisAsSvg");
    }
    
    function exportTableAsCsv() {
        console.log("BOGUS BarChartVis.exportTableAsCsv");
    }
    
    function exportTableAsJson() {
        console.log("BOGUS BarChartVis.exportTableAsJson");
    }
})();



/*******************************************************************************
 * 
 * Define the structures that embed the visualization into HTML simple for one
 * journal. full (multiple views and export buttons) for one journal.
 * 
 * Also, define the functions that another site might want to override.
 * 
 ******************************************************************************/

ScholarsVis["JournalBarChart"] = {
        transform: BarChartVis.transformdata,
        display: BarChartVis.display,
        closer: BarChartVis.close,
        
        Visualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/journalBarChart?journal=" + options.journal,
                    transform : BarChartVis.transformdata,
                    display : BarChartVis.display,
                    closer : BarChartVis.close,
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        FullVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/journalBarChart?journal=" + options.journal,
                    transform : BarChartVis.transformdata,
                    views : {
                        vis : {
                            display : BarChartVis.display,
                            closer : BarChartVis.close,
                            export : {
                                json : {
                                    filename: "journalBarChart.json",
                                    call: BarChartVis.exportVisAsJson
                                },
                                svg : {
                                    filename: "journalBarChart.svg",
                                    call: BarChartVis.exportVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : BarChartVis.drawTable,
                            closer : BarChartVis.closeTable,
                            export : {
                                csv : {
                                    filename: "journalBarChartTable.csv",
                                    call: BarChartVis.exportTableAsCsv,
                                },
                                json : {
                                    filename: "journalBarChartTable.json",
                                    call: BarChartVis.exportTableAsJson
                                }
                            }
                        },
                        empty: {
                            display : d => {}
                        }
                    }
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}
