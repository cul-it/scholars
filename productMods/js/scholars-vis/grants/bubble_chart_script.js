var width = 600;
var height = 600;
var filtered = [];
var comeback = [];
var dateFiltered = []; 
var dateComeback = [];

var clicked = false; 
  // Used when setting up force and
  // moving around nodes\
  var damper = 0.102;

  // tooltip for mouseover functionality
  var svg = null;
  var bubbles = null;
  var nodes = [];

    // tooltip for mouseover functionality
  var tooltip = CustomTooltip('grants_tooltip', 400);

  var svg = d3.select("#vis")
  .append('svg')
  .attr('width', width)
  .attr('height', height);

    // on which view mode is selected.
    var center = { x: width / 2, y: height / 2 };

    function charge(d) {
      return -Math.pow(d.radius, 2.0) / 8;
    }

    var force = d3.layout.force()
    .size([width, height])
    .charge(charge)
    .gravity(-0.01)
    .friction(0.9);


  // Nice looking colors - no reason to buck the trend
  var fillColor = d3.scale.ordinal()
  .domain(['unknown','low', 'medium', 'high'])
  .range(["#41B3A7","#81F7F3", "#819FF7", "#BE81F7"]);

  // Sizes bubbles based on their area instead of raw radius
  var radiusScale = d3.scale.pow()
  .exponent(0.5)
  .range([2, 15]);

  var currentRange = [];
  var removedNames = []; 


// d3.json("${urls.base}/data/grants.json", function(data){
//var visDisplay = function(data){
//var visDisplay = d3.json("${urls.base}/data/grants.json", function(error, data){
var visDisplay = function(json, target){
  update(json);
  grants = json;
  currentData = json.map(function(node){
    node["peopleList"] = node.people.map(d=>d.name); 
    return node;
  });
  var people = getNameList(grants);
  addList("#person", people, "Person"); 

  var departments = _.uniq(getDeptList(grants));
  addList("#department", departments, "Department");
                  
  var agencies = _.uniq(getFundingAgency(grants)); 
  addList("#funagen", agencies, "Funding Agency")

  var minYear = d3.min(grants, d=>Number(d.Start)); 
  var maxYear = d3.max(grants, d=>Number(d.End)); 

  currentRange  = [minYear, maxYear];

  var range = document.getElementById('range');
  noUiSlider.create(range, {
    start: [ minYear, maxYear], // Handle start position
    connect: true, // Display a colored bar between the handles
    step: 1, 
    tooltips: true,
    format: {
      to: function ( value ) {
        return value;
      },
      from: function ( value ) {
        return value;
      }
    }, 
    range: { // Slider can select '0' to '100'
      'min': minYear,
      'max': maxYear
    }, 
    // lets leave it here for now and not delete it.
    // pips: {
    //   mode: 'values',
    //   values: [minYear, maxYear], 
    //   density: 75
    // }
  });

  d3.select('#testInput').on('keyup', function() {
    var query = this.value.toLowerCase();
    $('.labelPerson').each(function(i, elem) {
      if(elem.innerHTML.toLowerCase().indexOf(query) != -1) {
        $(this).closest('label').show();
        $(this).prev().show();
      }else{
        $(this).closest('label').hide();
        $(this).prev().hide();
      }
    });
  });

  d3.select('#deptInput').on('keyup', function() {
    var query = this.value.toLowerCase();
    $('.labelDepartment').each(function(i, elem) {
      if(elem.innerHTML.toLowerCase().indexOf(query) != -1) {
        $(this).closest('label').show();
        $(this).prev().show();
      }else{
        $(this).closest('label').hide();
        $(this).prev().hide();
      }
    });
  });

  d3.select('#fundingInput').on('keyup', function() {
    var query = this.value.toLowerCase();
    $('.labelFunding.Agency').each(function(i, elem) {
      if(elem.innerHTML.toLowerCase().indexOf(query) != -1) {
        $(this).closest('label').show();
        $(this).prev().show();
      }else{
        $(this).closest('label').hide();
        $(this).prev().hide();
      }
    });
  });
  
  range.noUiSlider.on("change", function(values, handle){
    currentData = currentData.filter(function(d){
      if((d.Start >= values[0] && d.Start <= values[1])||(d.End <= values[1] && d.End >= values[0])){ 
        return true;
      }else{
        dateFiltered.push(d);
        return false; 
      }
    });

    if ((values[0] < currentRange[0]) || (values[1] > currentRange[1])){
      dateFiltered = dateFiltered.filter(function(d){
        if((d.Start >= values[0] && d.Start <= values[1])||(d.End <= values[1] && d.End >= values[0])){
          dateComeback.push(d);
          return false; 
        }else{
          return true;
        }
      }); 
    }

    currentData = currentData.concat(dateComeback);
    currentRange = values;
    update(currentData); 
    updateChecks(); 
    dateComeback = [];
  });

  var legendWidth = 300; 
  var legendHeight = 300;
  var legend = d3.select("#legendDiv").append("svg").attr("width", legendWidth).attr("height", legendHeight); 
  var domainValues = ["Unknown", "< $100,000", "$100,000 - $1,000,000", "> $1,000,000"];
  legend.append('text').attr('x',5).attr('y', 12).style("font-weight", "bold").style("margin-bottom","20px").text("Color Scheme");
  fillColor.range().forEach(function(color, i){
    legend.append('rect').attr("width", 20).attr("height", 20).attr("x", 5).attr("y", 25 + i*25).style("fill", color);
    legend.append('text').attr("x", 42).attr("y", 20 + 20 + i*25).attr("alignment-baseline", "hanging").attr("text-anchor", "start").style("font-size", 16).text(domainValues[i]);
  })
} // end of function visDisplay()

function createGrantNodes(rawData) {
  var myNodes = rawData.map(function (d) {
    return {
      id: d.id,
      radius: radiusScale(+d.Cost),
      dept: d.dept, 
      value: d.Cost,
      start: d.Start,
      grant: d.grant, 
      end: d.End,
      people: d.people,
      name: d.grant.title,
      group: d.group,
      x: Math.random() * 900,
      y: Math.random() * 800, 
      funagen : d.funagen
    };
  });
  // sort them to prevent occlusion of smaller nodes.
  myNodes.sort(function (a, b) { return b.value - a.value; });
  return myNodes;
} //end of function createGrantNodes()

function update(rawData){
  ttip();
  var maxAmount = d3.max(rawData, function (d) { return +d.Cost; });
  radiusScale.domain([0, maxAmount]);
  nodes = createGrantNodes(rawData);
  d3.select("#vis").selectAll(".bubble").data([]).exit().remove(); 
  
  // Set the force's nodes to our newly created nodes array.
  force.nodes(nodes);

  // Bind nodes data to what will become DOM elements to represent them.
  bubbles = svg.selectAll('.bubble')
    .data(nodes, function (d) { return d.id; });

  // Create new circle elements each with class `bubble`.
  // There will be one circle.bubble for each object in the nodes array.
  // Initially, their radius (r attribute) will be 0.
  bubbles.enter().append('circle')
    .classed('bubble', true)
    .attr('r', 0)
    .attr('fill', function (d) { return fillColor(d.group); })
    .attr('stroke', function (d) { return d3.rgb(fillColor(d.group)).darker(); })
    .attr('stroke-width', 2)
    .on('mouseover', showDetail)
    .on('mouseout', hideDetail)
    .on('click', clickFunction);

  // Fancy transition to make bubbles appear, ending with the
  // correct radius
  bubbles.transition()
    .duration(500)
    .attr('r', function (d) { return d.radius; });

  groupBubbles();

  function moveToCenter(alpha) {
    return function (d) {
      d.x = d.x + (center.x - d.x) * damper * alpha;
      d.y = d.y + (center.y - d.y) * damper * alpha;
    };
  }
  
  function groupBubbles() {
    force.on('tick', function (e) {
      bubbles.each(moveToCenter(e.alpha))
        .attr('cx', function (d) { return d.x; })
        .attr('cy', function (d) { return d.y; });
    });
    force.start();
  }
} // end of function update()

function addCommas(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',' + '$2');
  }
  return x1 + x2;
}

new ScholarsVis.Visualization({
  target : '#vis',
  url : applicationContextPath + "/api/dataRequest/grants_bubble_chart",
  transform : transformGrantsData,
  display : visDisplay,
  closer : closeGrantsVis
}).show()




