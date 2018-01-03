var BarChartVis = (function() {
    return {
        transformdata: transformdata,
        display: display,
        closer: closer,
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
            var highest = new Date().getFullYear();
            var lowest = bindings.reduce(function(lowest, binding) {
                return Math.min(lowest, parseInt(binding.date.value.substring(0, 4)));
            }, 9999);
            if (options.lowestYear) {
                lowest = Math.max(lowest, options.lowestYear);
            }
            console.log("LOWEST: " + lowest + ", HIGHEST: " + highest);
            
            var years = [];
            for (var y = lowest; y <= highest; y++) {
                years.push(y.toString());
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
            bindings.forEach(processBinding);
            return map;
            
            function processBinding(binding) {
                var unit = binding.unitName.value;
                var year = binding.date.value.substring(0, 4);
                var articleUri = binding.article.value;
                var articleTitle = binding.title.value;
                if (map[unit][year]) { // The lower years might have been truncated!
                    map[unit][year][articleTitle] = articleUri;
                }
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
        var chartDiv = $("<div id='jbc'></div>").appendTo(target);
        var chart = c3.generate({
            bindto: chartDiv[0],
            data: {
                columns: data.columnData,
                type: 'bar',
                groups: [data.units],
                onclick: showDetailsPanel
            },
            legend: {
                position: 'bottom'
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
                        rotate: 75,
                        multiline: false
                    },
                    type: 'category',
                    categories: data.years
                }},
                tooltip: {
                    grouped: false // Default true
                }
        });
        
        function showDetailsPanel(d, element) {
            if ($('.c3-tooltip-container:visible').length == 0) {
                return;
            }
            
            var panel = addPanel();
            var tip = replaceTooltipWithDetailtip();
            var desiredSize = addDetailsAndPlayWithSizes();
            animate();
            
            /*
             * Create a panel that will block mouse events from the chart. Click
             * on it, and it will go away.
             */
            function addPanel() {
                var panel = $('<div class="transparentPanel"></div>');
                panel.appendTo(chartDiv);
                panel.click(removePanel);
                return panel;
                
                function removePanel(event) {
                    panel.remove();
                }
            }
            
            /*
             * Create the detail tip as a copy of the tooltip. Recognize mouse
             * events, but don't pass them on to the panel.
             */
            function replaceTooltipWithDetailtip() {
                var tooltip = $('.c3-tooltip-container'); 
                tooltip.hide();
                
                var detail = tooltip.clone();
                detail.addClass('detailTooltip');
                detail.appendTo(panel);
                detail.show();
                
                detail.css('pointer-events', 'auto');
                detail.click(blockClicks);
                
                return detail;
                
                function blockClicks(event) {
                    event.stopPropagation();
                }
            }

            function addDetailsAndPlayWithSizes() {
                var originalSize = {
                        top: tip.position().top,
                        left: tip.position().left,
                        height: tip.height(),
                        width: tip.width()
                };
                
                hideAndAddDetails();
                
                var desiredSize = {
                        top: 20,
                        left: Math.floor((panel.width() - tip.width()) / 2),
                        height: tip.height(),
                        width: tip.width()
                }
                
                restoreOriginalSize();
                
                return desiredSize;
                    
                function hideAndAddDetails() {
                    var table = $('<table class="c3-tooltip details"><tbody></tbody></table>');
                    var tbody = table.find('tbody');
                    var articles = data.articles[d.id][data.years[d.index]];
                    Object.keys(articles).sort().forEach(addTableRow);
                    
                    tip.css("opacity", 0.01);
                    tip.css("left", Math.floor(panel.width() / 4));
                    tip.css("top", Math.floor(panel.height() / 4));
                    tip.append(table);
                    table.width(tip.width());
                    
                    function addTableRow(title) {
                        var link = ScholarsVis.Utilities.toDisplayUrl(articles[title]);
                        tbody.append($('<tr><td class="name"><a href="' + link + '">' + title + '</a></td></tr>'));
                    }
                }
                
                function restoreOriginalSize() {
                    tip.css("top", originalSize.top + "px");
                    tip.css("left", originalSize.left + "px");
                    tip.height(originalSize.height);
                    tip.width(originalSize.width);
                    tip.css("opacity", 1.0);
                }
            }
            
            function animate() {
                tip.animate(desiredSize);
            }
        }
    }
    
    function closer(target) {
        $("#jbc").remove();
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
        closer: BarChartVis.closer,
        
        Visualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/journalBarChart?journal=" + options.journal,
                    transform : BarChartVis.transformdata,
                    display : BarChartVis.display,
                    closer : BarChartVis.closer,
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
                            closer : BarChartVis.closer,
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
                    },
                    lowestYear: 2000
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}
