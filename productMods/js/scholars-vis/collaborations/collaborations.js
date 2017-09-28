ScholarsVis["CrossUnitCollaborationSunburst"] = function(options) {
    var defaults = {
            url : applicationContextPath + "/api/dataRequest/cross_unit_sunburst?department=" + options.department,
            transform : transformCollab,
            views : {
                vis : {
                    display : sunburst,
                    closer : closeSunburst,
                    export : {
                        json : {
                            filename: "crossUnitCollaboration.json",
                            call: exportSunburstVisAsJson
                        },
                        svg : {
                            filename: "crossUnitCollaboration.svg",
                            call: exportSunburstVisAsSvg
                        }
                    }
                },
                table: {
                    display : drawCrossUnitTable,
                    closer : closeCrossUnitTable,
                    export : {
                        csv : {
                            filename: "crossUnitCollaborationTable.csv",
                            call: exportCrossUnitTableAsCsv,
                        },
                        json : {
                            filename: "crossUnitCollaborationTable.json",
                            call: exportCrossUnitTableAsJson
                        }
                    }
                }
            }
    };
    return new ScholarsVis.Visualization(options, defaults);
};

ScholarsVis["InterDepartmentCollaborationSunburst"] = function(options) {
    var defaults = {
            url : applicationContextPath + "/api/dataRequest/interdepartmental_sunburst?department=" + options.department,
            transform : transformCollab,
            views : {
                vis : {
                    display : sunburst,
                    closer : closeSunburst,
                    export : {
                        json : {
                            filename: "interDepartmentCollaboration.json",
                            call: exportSunburstVisAsJson
                        },
                        svg : {
                            filename: "interDepartmentCollaboration.svg",
                            call: exportSunburstVisAsSvg
                        }
                    }
                },
                table: {
                    display : drawInterDepartmentTable,
                    closer : closeInterDepartmentTable,
                    export : {
                        csv : {
                            filename: "interDepartmentCollaborationTable.csv",
                            call: exportInterDepartmentTableAsCsv,
                        },
                        json : {
                            filename: "interDepartmentCollaborationTable.json",
                            call: exportInterDepartmentTableAsJson
                        }
                    }
                }
            }
    };
    return new ScholarsVis.Visualization(options, defaults);
};

/*******************************************************************************
 * Take the data that comes from the server and add display URLs wherever you
 * find URIs.
 *
 * The raw data looks like this:
 *
 * {
 *   "name": "EN",
 *   "description": "College of Engineering",
 *   "children": [
 *     {
 *       "name": "AEP",
 *       "description": "Applied and Engineering Physics",
 *       "children": [
 *         {
 *           "name": "Kusse, Bruce Raymond",
 *           "description": "Kusse, Bruce Raymond",
 *           "orgCode": "AEP",
 *           "uri": ""http://scholars.cornell.edu/individual/brk2",
 *           "children": [
 *             {
 *               "name": "Hammer, David A.",
 *               "description": "Hammer, David A.",
 *               "orgCode": "ECE",
 *               "pubs": [
 *                 {
 *                   "uri": "http://scholars.cornell.edu/individual/UR-303820",
 *                   "title": "Experiments measuring the initial energy...",
 *                   "date": "2001-01-01T00:00:00"
 *                 },
 *                 ...
 *               ],
 *               "uri": "http://scholars.cornell.edu/individual/mls50",
 *               "size": 1
 *             },
 *             ...
 *           ]
 *         },
 *         ...
 *       ]
 *     },
 *     ...
 *   ]
 * }
 *
 ******************************************************************************/
function transformCollab(rawData) {
    var dataCopy = jQuery.extend(true, {}, rawData);
    return transformNode(dataCopy);
    
    function transformNode(node) {
        if (node.uri) {
            node.url = toDisplayPageUrl(node.uri);
        }
        if (node.children) {
            node.children = node.children.map(transformNode);
        }
        if (node.pubs) {
            node.pubs = node.pubs.map(transformNode);
        }
        return node;
    }
}

function closeSunburst(target) {
	$(target).children("svg").remove();
	$('div#tooltip').remove();
	$('div.d3-tip').remove();
}

function sunburst(json_data, target) {
var width = $(target).width();
var height = $(target).height()-50;

var margin = {top: 300, right: 310, bottom: 300, left: 310},
    // radius = Math.min(margin.top, margin.right, margin.bottom, margin.left) - 10;
       radius = Math.min(width, height) / 2 - 10;

function filter_min_arc_size_text(d, i) {return (d.dx*d.depth*radius/3)>14}; 

/*var hue = function(i) {
  var colors = ["#006699", "#cc3333", "#ffcc33", "#cc6699", "#9966cc", "#669900", "#00ffcc", "#ff9933"];
  return colors[i % colors.length];
}*/

var hue = d3.scale.category10();
hue.range([,"#cc3333", "#669900","#006699", "#00ffcc ", "#cc6699",  "#9966cc", "#ffcc33" ,"#ff9933"]);
/* 6 - */
var luminance = d3.scale.sqrt()
    .domain([3, 1e4])
    .clamp(true)
    .range([90, 20]);

var tip = d3.tip().attr('class', 'd3-tip choices triangle-isosceles').attr("id", "specificTip").html(function(d) { 
  result = "";
  if(d.url != null){
    result += "<p><b><a href='" + d.url + "'>" + d.name + " ("+d.pubs.length+") </a></b></p>";
  }else{
    result += "<p class='nonlinktext'>"+ d.name + " ("+d.pubs.length+")</p> ";
  }
  if(typeof d.pubs != "undefined") {
    for(var i = 0; i < d.pubs.length; i++) {
      result += "<div class='collabhoverable'><a href='" + d.pubs[i].url + "'>" +(i+1)+". "+d.pubs[i].title + "</a></div>";
    }
  }
  else {
    result += "No publications found";
  } 
  return result;
  });

var svg = d3.select(target).append("svg")
    .attr("id", "svgDiv")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")").call(tip);

//remove any existing crumbs entity and create a new one.
d3.select("#crumbs").remove();
var crmb = d3.select(target).append("div")
    .attr("id", "crumbs")
    .append("ul")
      .attr("id", "crumbList")
      .attr("class", "cwbreadcrumb");

var nodeList = [];
// bring to initial stage
updateCrumbs([]);

var partition = d3.layout.partition()
    .sort(function(a, b) { return d3.ascending(a.name, b.name); })
    .size([2 * Math.PI, radius])

var arc = d3.svg.arc()
    .startAngle(function(d) { return d.x; })
    .endAngle(function(d) { return d.x + d.dx - .01 / (d.depth + .5); })
    .innerRadius(function(d) { return radius / 3 * d.depth; })
    .outerRadius(function(d) { return radius / 3 * (d.depth + 1) - 1; });

//Tooltip description
var tooltip = d3.select("body")
    .append("div")
    .attr("id", "tooltip")
    .style("position", "absolute")
    .style("z-index", "18")
    .style("opacity", 0);

function format_number(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}


function format_description(d) {
  var description = d.description;
  if(d.description === d.name){
    return  '<b>' + d.description+ '</b>';
    //+'<br> (' + format_number(d.value) + ')'; // This number does not represent the # of articles one unit or person has written in collaboration with others.
    // It is the number of coauthors of person A with other persons and a single article may have multiple interdept or crossunit coauthorships.
  }else
    return  '<b>' + d.description+' ('+d.name+') '+ '</b>';
    //+'<br> (' + format_number(d.value) + ')'; // This number does not represent the # of articles one unit or person has written in collaboration with others.
    // It is the number of coauthors of person A with other persons and a single article may have multiple interdept or crossunit coauthorships.
  end
      
}

function computeTextRotation(d) {
  var angle=(d.x +d.dx/2)*180/Math.PI - 90 ; 
  return "rotate(" + angle+ ")translate(0,0)";
}

function mouseOverArc(d) {
       d3.select(this).attr("stroke","gray")
       
          tooltip.html(format_description(d));
          return tooltip.transition()
            .duration(50)
            .style("opacity", 0.9);
        }

function mouseOutArc(){
  d3.select(this).attr("stroke","")
  return tooltip.style("opacity", 0);
}

function mouseMoveArc (d) {
          return tooltip
            .style("top", (d3.event.pageY-10)+"px")
            .style("left", (d3.event.pageX+10)+"px");
}

function getLastName(s){
  return s.split(',')[0];
}

function getAngle(d) {
  var thetaDeg = (180 / Math.PI * (arc.startAngle()(d) + arc.endAngle()(d)) / 2 - 90);
  return (thetaDeg > 90) ? thetaDeg - 180 : thetaDeg;
}

function draw_it(root, target) {
	var error;
// d3.json("https://raw.githubusercontent.com/amizra/vivo-visualization/master/sunburst/engineering.json?token=ABkfSVsspdFyAYHzUdQQZ1VM5qAKfGNPks5XDq9iwA%3D%3D", function(error, root) {
  if (error) return console.warn(error);
  // Compute the initial layout on the entire tree to sum sizes.
  // Also compute the full name and fill color for each node,
  // and stash the children so they can be restored as we descend.
  
  partition
      .value(function(d) { return d.size; })
      .nodes(root)
      .forEach(function(d, i) { nodeList.push(d);  d.sum = d.value; })


  partition.nodes(root)    
      .forEach(function(d, i) {
        d._children = d.children;
        d.fill = fill(d);
        d.key = key(d);
      });

  // Now redefine the value function to use the previously-computed sum.
  partition
      .children(function(d, depth) { return depth < 2 ? d._children : null; })
      .value(function(d) { return d.sum; });

  var center = svg.append("circle")
      .attr("r", radius / 3).on("click", zoomOut);
  // why specificly defined as Engineering. This will not work for other units.

  var defaultFontSize = 11;
  var newFontSize = defaultFontSize - root.description.length/defaultFontSize;
  //var scaleFactor = -2.9*newFontSize;
  var centerText = svg.append("text").style("text-anchor", "middle").style("font-size", newFontSize).text(function(d) { return root.description});
  

  center.append("title")
      .text("zoom out");
      
  var partitioned_data=partition.nodes(root).slice(1)

  var path = svg.selectAll("path")
      .data(partitioned_data)
    .enter().append("path")
      .attr("d", arc)
      .style("fill", function(d) { return d.fill; })
      .each(function(d) { this._current = updateArc(d); })
      .on("click", zoomIn)
    .on("mouseover", mouseOverArc)
      .on("mousemove", mouseMoveArc)
      .on("mouseout", mouseOutArc);
  
      
var texts = svg.selectAll("text")
  .data(partition.nodes(root))
  .enter()
  .append("text")
  .filter(filter_min_arc_size_text)  
    .attr("x", function(d) { d[1]; })  
    .attr("dx", "0") // margin
    .attr("dy", ".35em") // vertical-align  
    .attr("text-anchor", "middle")
    .attr("transform", function(d) { 
      return "translate(" + arc.centroid(d) + ")" + "rotate(" + getAngle(d) + ")"; 
    })
    .attr("font-size", 9)    
  
  .text(function(d,i) {
      return getLastName(d.name); 
  });

  function zoomIn(p) {
    if (p.depth > 1) p = p.parent;
    if (!p.children) {
		tip.show(p);
		return;
	}
    zoom(p, p);
  }

  function zoomOut(p) {
	tip.hide(p);
    if(typeof p == "undefined") return;
    if (!p.parent) return;
    zoom(p.parent, p);
  }

  // Zoom to the specified new root.
  function zoom(root, p) {
    if (document.documentElement.__transition__) return;

    // Rescale outside angles to match the new layout.
    var enterArc,
        exitArc,
        outsideAngle = d3.scale.linear().domain([0, 2 * Math.PI]);

    function insideArc(d) {
      return p.key > d.key
          ? {depth: d.depth - 1, x: 0, dx: 0} : p.key < d.key
          ? {depth: d.depth - 1, x: 2 * Math.PI, dx: 0}
          : {depth: 0, x: 0, dx: 2 * Math.PI};
    }

    function outsideArc(d) {
      return {depth: d.depth + 1, x: outsideAngle(d.x), dx: outsideAngle(d.x + d.dx) - outsideAngle(d.x)};
    }

    center.datum(root);

    // When zooming in, arcs enter from the outside and exit to the inside.
    // Entering outside arcs start from the old layout.
    if (root === p) enterArc = outsideArc, exitArc = insideArc, outsideAngle.range([p.x, p.x + p.dx]);
  
   var new_data=partition.nodes(root).slice(1)

    path = path.data(new_data, function(d) { return d.key; });
     
   // When zooming out, arcs enter from the inside and exit to the outside.
    // Exiting outside arcs transition to the new layout.
    if (root !== p) enterArc = insideArc, exitArc = outsideArc, outsideAngle.range([p.x, p.x + p.dx]);

    d3.transition().duration(d3.event.altKey ? 7500 : 750).each(function() {
      path.exit().transition()
          .style("fill-opacity", function(d) { return d.depth === 1 + (root === p) ? 1 : 0; })
          .attrTween("d", function(d) { return arcTween.call(this, exitArc(d)); })
          .remove();
          
      path.enter().append("path")
          .style("fill-opacity", function(d) { return d.depth === 2 - (root === p) ? 1 : 0; })
          .style("fill", function(d) { return d.fill; })
          .on("click", zoomIn)
       .on("mouseover", mouseOverArc)
         .on("mousemove", mouseMoveArc)
         .on("mouseout", mouseOutArc)
          .each(function(d) { this._current = enterArc(d); });

    
      path.transition()
          .style("fill-opacity", 1)
          .attrTween("d", function(d) { return arcTween.call(this, updateArc(d)); });
          
      var defaultFontSize = 11;
      var newFontSize = defaultFontSize - root.description.length/defaultFontSize;
      //var scaleFactor = -2.9*newFontSize;
      centerText.style("font-size", newFontSize+"px").style("text-anchor", "middle").text(root.description);
      
      if(typeof root.children[0].children === "undefined") {
          svg.selectAll('path').on('click', function(d) { 
            tip.show(d);
            //Handling case where user switches from professor to professor. 
              if(crumbs.slice(-1)[0]==="term"){
                crumbs.pop()
                crumbs.pop();
                crumbs.push(d.name+" ("+d.orgCode+")");
                crumbs.push("term"); 
                var len = crumbs.length-1;
                updateCrumbs(crumbs.slice(0, len))
              }
              else{
                crumbs.push(d.name+" ("+d.orgCode+")");
                crumbs.push("term"); 
                var len = crumbs.length-1;
                updateCrumbs(crumbs.slice(0, len))
              }
          });
          d3.select("body").selectAll("#specificTip").on('click', function(d){
            //closes the tooltip when clicked (Anywhere except links)
            tip.hide();
          });  
        } else {
          tip.hide();
          svg.selectAll('path').on('click', zoomIn);
        }
      
      //Breadcrumbs
      var crumbs = [];

      //construct list of nodes. 
      if(root.orgCode){
        crumbs.push(root.name+" ("+root.orgCode+")");
      }else{
        crumbs.push(root.name); 
      }
      while(root.parent){
        crumbs.push(root.parent.name);
        root = root.parent;
      }  
      //not the best but only up to 4 elements in list. 
      crumbs.reverse();

      //change the UI
      updateCrumbs(crumbs);

    });
  
    
    
   texts = texts.data(new_data, function(d) { return d.key; })
   
    texts.exit()
    .remove()    
    texts.enter()
    .append("text"); 

    texts.style("opacity", 0)
    .attr("x", function(d) { d[1]; })  
    .attr("dx", "6") // margin
    .attr("dy", ".35em") // vertical-align  
    .attr("text-anchor", "middle")
    .attr("font-size", 9)
    .attr("transform", function(d) { 
      return "translate(" + arc.centroid(d) + ")" + "rotate(" + getAngle(d) + ")"; 
    })   
      .filter(filter_min_arc_size_text)     
      .text(function(d,i) {return getLastName(d.name)})
 //  .text(function(d,i) {return d.name})  truncating the names
 .transition().delay(750).style("opacity", 1)
        
     
  }
}

function key(d) {
  var k = [], p = d;
  while (p.depth) k.push(p.name), p = p.parent;
  return k.reverse().join(".");
}

function fill(d) {
  var p = d;
  while (p.depth > 1) p = p.parent;
  var c = d3.lab(hue(p.name));
  c.l = luminance(d.sum);
  return c;
}

function arcTween(b) {
  var i = d3.interpolate(this._current, b);
  this._current = i(0);
  return function(t) {
    return arc(i(t));
  };
}

function updateCrumbs(array){
  //remove existing crumbs 
  d3.selectAll(".crumbs").remove();

  //draw new crumbs
  var circles = d3.select("#crumbList").selectAll(".crumbItems")
      .data(array)
      .enter()
      .append("li")
      .attr("class", "crumbs")
      .append("a")
      .text((d)=>d)
}

function updateArc(d) {
  return {depth: d.depth, x: d.x, dx: d.dx};
}

draw_it(json_data);

d3.select(self.frameElement).style("height", margin.top + margin.bottom + "px");
}

/*******************************************************************************
 * 
 * Export the visualization data.
 * 
 ******************************************************************************/
function exportSunburstVisAsJson(data, filename, options) {
    ScholarsVis.Utilities.exportAsJson(filename, trimDates());

    // Trim each date to just 4 characters.
    function trimDates() {
        var fullCopy = jQuery.extend(true, {}, data);
        fullCopy.children.forEach(trimCoorgData);
        return fullCopy;    
        
        function trimCoorgData(cod) {
            cod.children.forEach(trimAuthorData);
            
            function trimAuthorData(ad) {
                ad.children.forEach(trimCollabData);
                
                function trimCollabData(cd) {
                    cd.pubs.forEach(trimPubData);
                    
                    function trimPubData(pd) {
                        pd.date = pd.date.substring(0, 4);
                    }
                }
            }
        }
    }
}


function exportSunburstVisAsSvg(data, filename, options) {
    ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
}

/*******************************************************************************
 * 
 * Fill the Cross-unit Collaboration table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawCrossUnitTable(data, target, options) {
    var tableElement = $(target).find(".scholars-vis-table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForCrossUnitTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(createLink(rowData.authorName, rowData.authorUri), 
                formatOrg(rowData.authorAffiliationLabel, rowData.authorAffiliationCode), 
                createLink(rowData.coauthorName, rowData.coauthorUri), 
                formatOrg(rowData.coauthorAffiliationLabel, rowData.coauthorAffiliationCode),
                createLink(rowData.publicationTitle, rowData.publicationUri),
                rowData.publicationDate);
        
        function createLink(text, uri) {
            return "<a href='" + toDisplayPageUrl(uri) + "'>" + text + "</a>"
        }
        
        function formatOrg(label, code) {
            return label + " (" + code + ")";
        }
    }
}

function closeCrossUnitTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportCrossUnitTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForCrossUnitTable(data));
}

function exportCrossUnitTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForCrossUnitTable(data));
}

function transformAgainForCrossUnitTable(data) {
    var tableData = [];
    var orgLabels = mapOrgCodesToLabels();
    data.children.forEach(doCollab);
    return tableData;

    function mapOrgCodesToLabels() {
        var map = {};
        mapOrgCode(data); // Include the top-level org.
        data.children.forEach(mapOrgCode);
        return map;
        
        function mapOrgCode(org) {
            map[org.name] = org.description;
        }
    }
    
    function doCollab(collabStruct) {
        collabStruct.children.forEach(doAuthor);
        
        function doAuthor(authorStruct) {
            authorStruct.children.forEach(doCoauthor);
            
            function doCoauthor(coauthorStruct) {
                coauthorStruct.pubs.forEach(doPub);
                
                function doPub(pubStruct) {
                    tableData.push({
                        authorAffiliationCode: authorStruct.orgCode, 
                        authorAffiliationLabel: orgLabels[authorStruct.orgCode],
                        authorName: authorStruct.name,
                        authorUri: authorStruct.uri,
                        coauthorAffiliationCode: coauthorStruct.orgCode,
                        coauthorAffiliationLabel: orgLabels[coauthorStruct.orgCode],
                        coauthorName: coauthorStruct.name,
                        coauthorUri: coauthorStruct.uri,
                        publicationTitle: pubStruct.title,
                        publicationDate: pubStruct.date.substring(0, 4),
                        publicationUri: pubStruct.uri
                    });
                }
            }    
        }
    }
}

/*******************************************************************************
 * 
 * Fill the Inter-department Collaboration table with data, draw it, export it.
 * 
 * For now, this is exactly the same as the Cross-Unit Collaboration Table.
 * 
 ******************************************************************************/
function drawInterDepartmentTable(data, target, options) {
    drawCrossUnitTable(data, target, options);
}

function closeInterDepartmentTable(target) {
    closeCrossUnitTable(target);
}

function exportInterDepartmentTableAsCsv(data, filename) {
    exportCrossUnitTableAsCsv(data, filename);
}

function exportInterDepartmentTableAsJson(data, filename) {
    exportCrossUnitTableAsJson(data, filename);
}
