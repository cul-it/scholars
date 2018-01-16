var BarChartVis = (function() {
    return {
        transformdata: transformdata,
        display: display,
        closer: closer,
        exportVisAsJson: exportVisAsJson,
        exportVisAsSvg: exportVisAsSvg,
        drawTable: drawTable,
        closeTable: closeTable,
        exportTableAsCsv: exportTableAsCsv,
        exportTableAsJson: exportTableAsJson
    };
    
    /*
     * Get: 
     *   - a sorted array of academic units, 
     *   - a sorted list of years, 
     *   - a double map of the articles, indexed by unit and year, 
     *   - a two-dimensional array of "column data", for the graph,
     *   - a value for the height of the tallest bar.
     */
    function transformdata(rawData, options) {
        var bindings = rawData.results.bindings;
        var units = enumerateUnits();
        var years = enumerateYears();
        var articlesMap = fillArticlesMap(createArticlesMap());
        var columnData = buildColumnData();
        var largestYValue = figurelargestYValue();
        
        return {
            units: units,
            years: years,
            articles: articlesMap,
            columnData: columnData,
            largestYValue: largestYValue
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
                lowest = Math.min(lowest, options.lowestYear);
            }
            
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
                if (map[unit][year]) { // The lower years might have been
                                        // truncated!
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
        
        function figurelargestYValue() {
            var max = 0;
            if (columnData.length > 0) {
                for (var col = 1; col < columnData[0].length; col++) {
                    var sum = 0;
                    for (var row = 0; row < columnData.length; row++) {
                        sum += columnData[row][col];
                    }
                    max = Math.max(max, sum);
                }
            }
            return max; 
        }
    }
    
    /*
     * Draw the bar graph.
     */
    function display(data, target, options) {
        var yAxisMax = adjustYAxisMax(data.largestYValue);
        var yAxisTicks = figureYAxisTicks(yAxisMax);
        
        console.log("Largest Y value: " + data.largestYValue + ", Y-Axis Max: " + yAxisMax);
        
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
                    label: {
                        text: 'Publication Count*',
                        position: 'outer-top'  
                    },
                    max: yAxisMax,
                    tick: {
                        values: yAxisTicks
                    }
                },
                x: {
                    height: 55, // leave room for the label text
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
        
        function figureYAxisTicks(yAxisMax) {
            var increments = [1, 2, 5, 10];
            var increment;
            for (var i = 0; i < increments.length; i++) {
                increment = increments[i];
                if (increment * 10 >= yAxisMax) {
                    break;
                }
            }
            
            var ticks = [0];
            var value = 0;
            while (value < yAxisMax) {
                value += increment;
                ticks.push(value);
            }
            return ticks;
        }
        
        function adjustYAxisMax(largestY) {
            if (!options.yAxisMax) {
                return max;
            }
            var expectedMax = options.yAxisMax;
            var expectedMin = (options.yAxisMin) ? options.yAxisMin : 0;
            if (largestY >= expectedMax) {
                return largestY;
            } else if (largestY <= expectedMin) {
                return expectedMin;
            } else {
                return Math.ceil(expectedMin + (expectedMax - expectedMin) * largestY / expectedMax);
            }
        }
        
        function showDetailsPanel(d, element) {
            // If there is no current tooltip, just skip it.
            if ($('.c3-tooltip-container:visible').length == 0) {
                return;
            }
            
            var panel = addPanel();
            var tip = replaceTooltipWithDetailtip();
            var desiredSize = addDetailsAndPlayWithSizes();
            tip.animate(desiredSize);
            
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

            /*
             * Hide the tip, add the details in secret, record the preferred
             * size, then push it back to its original size and show it again.
             */
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
                    var table = $('<table class="c3-tooltip details"><tbody><tr><td class="name"></td></tr></tbody></table>');
                    var tcell = table.find('td');
                    var articles = data.articles[d.id][data.years[d.index]];
                    Object.keys(articles).sort().forEach(addArticleToTable);
                    
                    tip.css("opacity", 0.01);
                    tip.css("left", Math.floor(panel.width() / 4));
                    tip.css("top", Math.floor(panel.height() / 4));
                    tip.append(table);
                    table.width(tip.width());
                    
                    function addArticleToTable(title, index) {
                        var link = ScholarsVis.Utilities.toDisplayUrl(articles[title]);
                        tcell.append($('<div class="hoverable"><a href="' + link + '">' + (index + 1) + ". " + title + '</a></div>'));
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
        }
    }
    
    function closer(target) {
        $("#jbc").remove();
    }
    
    function exportVisAsJson(data, filename) {
        ScholarsVis.Utilities.exportAsJson(filename, data);
    }
    
    function exportVisAsSvg(data, filename, options) {
        ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
    }
    
    function drawTable(data, target, options) {
        var tableElement = $(target).find(".vis_table").get(0);
        var table = new ScholarsVis.VisTable(tableElement);
        var tableData = transformAgainForTable(data);
        tableData.forEach(addRowToTable);
        table.complete();
        
        function addRowToTable(rowData) {
           table.addRow(rowData.publicationDate.toString(), rowData.academicUnit, rowData.title);
        }
    }

    function closeTable(target) {
        $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
    }

    function exportTableAsCsv(data, filename) {
        ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForTable(data));
    }
    
    function exportTableAsJson(data, filename) {
        ScholarsVis.Utilities.exportAsJson(filename, transformAgainForTable(data));
    }
    
    function transformAgainForTable(data) {
        var tableData = [];
        Object.keys(data.articles).forEach(doUnit);
        return tableData;
        
        function doUnit(unitName) {
            Object.keys(data.articles[unitName]).forEach(doUnitYear);

            function doUnitYear(year) {
                Object.keys(data.articles[unitName][year]).forEach(doArticle);
                
                function doArticle(articleName) {
                    tableData.push({
                        publicationDate: parseInt(year),
                        academicUnit: unitName,
                        title: articleName
                    });
                }
            }
        }
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
                    lowestYear: 2000,
                    yAxisMax: 30,
                    yAxisMin: 6
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}
