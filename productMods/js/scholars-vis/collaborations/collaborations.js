/**
 * Take the fake data that comes from the server and convert the URIs
 * to display page URLs.
 */
function transformCollab(fake) {
	return transformNode(fake)
	
	function transformNode(node) {
		if (node.uri) {
			node.uri = toDisplayPageUrl(node.uri);
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

function sunburst(json_data, target) {
var width = $(target).width();
var height = $(target).height();

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

var tip = d3.tip().attr('class', 'd3-tip choices triangle-isosceles').html(function(d) { 
  if(d.uri != null){
    result = "<p><b><a href='" + d.uri + "'>" + d.name + "</a></b></p>";
  }else{
    result = "<p class='nonlinktext'>" + d.name + "</p>";
  }
  if(typeof d.pubs != "undefined") {
    for(var i = 0; i < d.pubs.length; i++) {
      result += "<div class='collabhoverable'><a href='" + d.pubs[i].uri + "'>" +(i+1)+". "+d.pubs[i].title + "</a></div>";
    }
  }
  else {
    result += "No publications found";
  } 
  return result;
});

var svg = d3.select(target).append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + (width / 2) + "," + (height / 2) + ")").call(tip);

var nodeList = [];

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
    return  '<b>' + d.description+ '</b>'+'<br> (' + format_number(d.value) + ')';
  }else
    return  '<b>' + d.description+' ('+d.name+') '+ '</b>'+'<br> (' + format_number(d.value) + ')';
  end
      
}

function computeTextRotation(d) {
  var angle=(d.x +d.dx/2)*180/Math.PI - 90  
  
  return angle;
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

function truncate (s, length){
  var ellipsis = '...';
  if (s.length > length)
    return s.substring(0, length);
  else
    return s;
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
  var centerText = svg.append("text").attr("dx", function(d) { return -30; }).style("font-size", "11px").text(function(d) { return "Engineering "});
     

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
      .data(partitioned_data)
    .enter().append("text")
    .filter(filter_min_arc_size_text)     
      .attr("transform", function(d) { return "rotate(" + computeTextRotation(d) + ")"; })
    .attr("x", function(d) { return radius / 3 * d.depth; })  
    .attr("dx", "6") // margin
      .attr("dy", ".35em") // vertical-align  
      .text(function(d,i) {
        if(!d.uri == null){
          d.uri;
          return "<a href=\""+d.uri+"\">"+d.name+"</a>";
        }else{
          return d.name
        }
      }).on("click", function(d) {
        if(typeof d.uri != "undefined") {
          if(d.uri != null) {
            window.location.href = d.uri;
          }
        }
      })

  function zoomIn(p) {
    if (p.depth > 1) p = p.parent;
    if (!p.children) return;
    zoom(p, p);
  }

  function zoomOut(p) {
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
      var scaleFactor = -2.9*newFontSize;
      centerText.attr("dx", function(d) { return (scaleFactor/defaultFontSize)*root.description.length; }).style("font-size", newFontSize+"px").text(root.description);
      
      // if we're at depth 2, make tooltip visible

      if(typeof root.parent != "undefined") {
        if(typeof root.parent.parent != "undefined") {
          svg.selectAll('path').on('click', function(d) { 
            tip.show(d); 
            console.log(nodeList.indexOf(d));
          });
        }
        else {
          tip.hide();
          svg.selectAll('path').on('click', zoomIn);
        }
      }
     
         
    });
    
    
   texts = texts.data(new_data, function(d) { return d.key; })
   
   texts.exit()
           .remove()    
    texts.enter()
            .append("text").on("click", function(d) {
        if(typeof d.uri != "undefined") {
          if(d.uri != null) {
            window.location.href = d.uri;
          }
        }
      })
        
    texts.style("opacity", 0)
      .attr("transform", function(d) { return "rotate(" + computeTextRotation(d) + ")"; })
    .attr("x", function(d) { return radius / 3 * d.depth; })  
    .attr("dx", "6") // margin
      .attr("dy", ".35em") // vertical-align
      .filter(filter_min_arc_size_text)     
      .text(function(d,i) {return truncate(d.name, 15)})
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

function updateArc(d) {
  return {depth: d.depth, x: d.x, dx: d.dx};
}

draw_it(json_data);

d3.select(self.frameElement).style("height", margin.top + margin.bottom + "px");
}