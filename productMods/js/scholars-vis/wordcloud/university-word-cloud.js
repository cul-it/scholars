/*******************************************************************************
 * 
 * Define the structures that embed the visualization into HTML:
 *   person: simple and full
 *   department: simple and full
 * Where "full" includes the table view and the export functions.
 * 
 * Also, define the functions that another site might want to override.
 *
 ******************************************************************************/

ScholarsVis["UniversityWordCloud"] = {
        transform: transformUniversityWordcloud,
        display: drawUniversityWordCloud,
        closer: closeUniversityWordcloud,
        
        Visualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/university_word_cloud",
                    transform : transformUniversityWordcloud,
                    display : drawUniversityWordCloud,
                    closer : closeUniversityWordcloud,
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        FullVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/university_word_cloud",
                    transform : transformUniversityWordcloud,
                    views : {
                        vis : {
                            display : drawUniversityWordCloud,
                            closer : closeUniversityWordcloud,
                            export : {
                                json : {
                                    filename: "universityWordCloud.json",
                                    call: exportUniversityWcVisAsJson
                                },
                                svg : {
                                    filename: "universityWordCloud.svg",
                                    call: exportUniversityWcVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : drawUniversityWcTable,
                            closer : closeUniversityWcTable,
                            export : {
                                csv : {
                                    filename: "universityWordCloudTable.csv",
                                    call: exportUniversityWcTableAsCsv,
                                },
                                json : {
                                    filename: "universityWordCloudTable.json",
                                    call: exportUniversityWcTableAsJson
                                }
                            }
                        }
                    }
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}


/*******************************************************************************
 * 
 * Transform the RDF graph into the JSON structure that is expected by drawUniversityWordCloud
 * 
 * Output format:
 * [
 *   {
 *     "text": "Time Factors",
 *     "size": 224,
 *     "articleCount": 395,
 *     "entities": [
 *       {
 *         "text": "W  Butler",
 *         "uri": "/scholars/display/wrb2",
 *         "artcount": 15
 *       },
 *       ...
 *     ]
 *   },
 *   ...
 * ]
 * 
 ******************************************************************************/

function transformUniversityWordcloud(rawData) {
  return rawData.map(keywordStructToWordCloudData).sort(descendingBySize);
  
  function keywordStructToWordCloudData(kwStruct) {
    return {
      text : kwStruct.keyword,
      size : kwStruct.countByPerson,
      articleCount : kwStruct.countOfArticle,
      entities : kwStruct.persons.map(personToEntity).sort(
          descendingByArticleCount),
    }
    
    function personToEntity(pStruct) {
      return {
        text : pStruct.personName,
        uri : ScholarsVis.Utilities.toDisplayUrl(pStruct.personURI),
        artcount : pStruct.articleCount
      }
    }
    
    function descendingByArticleCount(a, b) {
      return b.artcount - a.artcount;
    }
  }
  
  function descendingBySize(a, b) {
    return b.size - a.size;
  }
}

function closeUniversityWordcloud(target) {
  $(target).children("svg").remove();
  $('div#tooltip').remove();
  $('div.d3-tip').remove();
}

function drawUniversityWordCloud(keywords, target) {
  var tip = createTooltip();
  activateInfoButton();
  refreshWordCloud();
  
  function activateInfoButton() {
    $('[data-toggle="tooltip"]').tooltip();
  }
  
  function createTooltip() {
    return d3.tip()
    .attr('class', 'sitewc-tip d3-tip choices triangle-isosceles')
    .html(produceTooltipHtml);
    
    function produceTooltipHtml(d) {
      return d.entities.map(htmlForEntity).join('');
      
      function htmlForEntity(ent, i) {
        return "<div class='hoverable'>" 
        + "<a href='" + ent.uri + "'>" + (i + 1) + ". " + ent.text + " (" + ent.artcount + ")</a>"
        + "</div>";
      }
    }
  }
  
  function refreshWordCloud() {
    var fills = d3.scale.category20();
    
    var margin_height = 20;
    var margin_width = 20;
    var height = $(target).height() - margin_height;
    var width = $(target).width() - margin_width;
    
    keywords.forEach((kw, i) => kw.fillColor=fills(i));
    
    var keywordScale = d3.scale.linear().range([ 5, 50 ]).domain(
        [ d3.min(keywords, d => d.size), d3.max(keywords, d => d.size) ]);
    
    d3.layout.cloud()
    .size([ width, height ])
    .words(keywords)
    .rotate(d => ~~(Math.random() * 2) * 90)
    .font("Tahoma")
    .fontSize(d => keywordScale(d.size))
    .on("end", draw)
    .start();
    
    function draw(words) {
      d3.select(target)
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("id", "stage")
      .append("g")
      .attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")")
      .selectAll("text")
      .data(words)
      .enter()
      .append("text")
      .style("font-size", d => d.size + "px")
      .style("font-family", "Tahoma")
      .style("fill", d => d.fillColor)
      .attr("text-anchor", "middle")
      .attr("transform", d => "translate(" + [ d.x, d.y ] + ")rotate(" + d.rotate + ")")
      .text(d => d.text)
      .call(tip)
      .on('click', tip.show)
      .on('mouseover', handleMouseover)
      .on('mouseout', restoreColor);
      
      function handleMouseover(d) {
        d3.select(this).style("cursor", "pointer");
        d3.select(this).style("fill", brightenColor(d));
        d3.select("#content").html(getHtmlString(d));
        
        function brightenColor(d) {
          return toRgbString(brighten(parseRgb(d.fillColor), 40));
          
          function parseRgb(color) {
            return [ parseInt(color.substr(1, 2), 16),
              parseInt(color.substr(3, 2), 16),
              parseInt(color.substr(5, 2), 16) ];
          }
          
          function brighten(rgbs, p) {
            return rgbs.map(i => Math.min(i + p, 255));
          }
          
          function toRgbString(rgbs) {
            return "rgb(" + rgbs.join(',') + ")";
          }
        }
        
        function getHtmlString(d) {
          return '<b>' + d.text + '</b>,'
          + '<font class="text-muted"> person count: ' + d.entities.length
          + '</font>, ' + '<font class="text-warning">article count: '
          + d.articleCount + '</font>';
        }
      }
      
      function restoreColor(d) {
        d3.select(this).style("fill", d.fillColor);
      }
    }
  }
  
  $(document).click(
      function(e) {
        if (!$(e.target).closest('text').length && !$(e.target).is('text')) {
          tip.hide();
          d3.select("#content").text('');
        }
      }
  );

}

/*******************************************************************************
 * 
 * Export the visualization data.
 * 
 ******************************************************************************/
function exportUniversityWcVisAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, data);
}

function exportUniversityWcVisAsSvg(data, filename, options) {
    ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
}

/*******************************************************************************
 * 
 * Fill the University Word Cloud table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawUniversityWcTable(data, target, options) {
    var tableElement = $(target).find(".vis_table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForUniversityTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(rowData.keyword, createLink(rowData.name, rowData.uri), rowData.pubCount);
        
        function createLink(text, uri) {
            return "<a href='" + uri + "'>" + text + "</a>"
        }
    }
}

function closeUniversityWcTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportUniversityWcTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForUniversityTable(data));
}

function exportUniversityWcTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForUniversityTable(data));
}

function transformAgainForUniversityTable(data) {
    var tableData = [];
    data.forEach(doKeyword);
    return tableData;
    
    function doKeyword(keywordData) {
        keywordData.entities.forEach(doEntity); 
        
        function doEntity(entityData) {
            var row = {
                    keyword: keywordData.text,
                    name: entityData.text,
                    pubCount: entityData.artcount,
                    uri: entityData.uri
            };
            tableData.push(row);
        }
    }
}

