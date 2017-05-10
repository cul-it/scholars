ScholarsVis["SiteGrants"] = function(options) {
    var defaults = {
            url : applicationContextPath + "/api/dataRequest/grants_bubble_chart",
            transform : transformGrantsData,
            display : displayWithControls,
            closer : closeGrantsVis,
    };
    return new ScholarsVis.Visualization(options, defaults);
};

ScholarsVis["DepartmentGrants"] = function(options) {
    var defaults = {
            url : applicationContextPath + "/api/dataRequest/grants_bubble_chart",
            transform : transformGrantsData,
            display : displayWithoutControls,
            closer : closeGrantsVis,
    };
    return new ScholarsVis.Visualization(options, defaults);
};

function displayWithControls(json, target, options){
    var display = new GrantsDisplay(target, options.legendDiv);
    new GrantsController(json, display, options);
    display.update(json);
} 

function displayWithoutControls(json, target, options){
    var display = new GrantsDisplay(target, options.legendDiv);
    display.update(json);
} 

function GrantsController(grants, display, options) {
    var filtered = grants;
    var currentPeople;
    var currentUnits;
    var currentAgencies;
    var currentDates;
    
    var personPanel = new AccordionControls.Checklist(options.personChecklistPanel, personChanged);
    personPanel.loadData(getPersonNames());
    
    var unitPanel = new AccordionControls.Checklist(options.unitChecklistPanel, unitChanged);
    unitPanel.loadData(getUnitNames());
    
    var agencyPanel = new AccordionControls.Checklist(options.agencyChecklistPanel, agencyChanged);
    agencyPanel.loadData(getAgencyNames());
    
    var dateRange = new AccordionControls.RangeSlider(options.dateRangePanel, yearChanged);
    dateRange.setRange(getYears());
    
    $(options.checkAllLink).click(checkAll);

    $(options.uncheckAllLink).click(uncheckAll);
    
    readControls();
    
    function getPersonNames() {
        return _.uniq(filtered.reduce(addNames, [])).sort(ignoreCaseSort);
        
        function addNames(names, grant) {
            return names.concat(grant.people.map(p => p.name));
        }
    }
    
    function getUnitNames() {
        return _.uniq(filtered.map(g => g.dept.name)).sort(ignoreCaseSort);
    }
    
    function getAgencyNames() {
        return _.uniq(filtered.map(g => g.funagen.name)).sort(ignoreCaseSort);
    }
    
    function ignoreCaseSort(a, b) {
        var aa = a.toUpperCase();
        var bb = b.toUpperCase();
        return (aa < bb) ? -1 : (aa > bb) ? 1 : 0;
    }
    
    function getYears() {
        var minYear = d3.min(grants, g=>Number(g.Start));
        var maxYear = d3.max(grants, g=>Number(g.End));
        return [minYear, maxYear];
    }
    
    function readControls() {
        currentPeople = personPanel.getChecked();
        currentUnits = unitPanel.getChecked();
        currentAgencies = agencyPanel.getChecked();
        currentDates = dateRange.getCurrentValues();
    }
    
    function personChanged() {
        readControls();
        filtered = grants.filter(yearFilter).filter(peopleFilter);
        updateChecks();
        updateDisplay();
        
        function peopleFilter(g) {
            return g.people.some(p => currentPeople.includes(p.name));
        }
    }
    
    function unitChanged() {
        readControls();
        filtered = grants.filter(yearFilter).filter(unitFilter);
        updateChecks();
        updateDisplay();
        
        function unitFilter(g) {
            return currentUnits.includes(g.dept.name);
        }
    }
    
    function agencyChanged() {
        readControls();
        filtered = grants.filter(yearFilter).filter(agencyFilter);
        updateChecks();
        updateDisplay();
        
        function agencyFilter(g) {
            return currentAgencies.includes(g.funagen.name);
        }
    }
    
    function yearChanged() {
        readControls();
        filtered = grants.filter(yearFilter);
        updateChecks();
        updateDisplay();
    }
    
    function yearFilter(g) {
        return Number(g.Start) <= currentDates[1] && Number(g.End) >= currentDates[0] ;
    }
    
    function checkAll() {
        filtered = grants;
        updateChecks();
        updateDisplay();
    }
    
    function uncheckAll() {
        filtered = [];
        updateChecks();
        updateDisplay();
    }
    
    function updateChecks() {
        personPanel.updateChecks(getPersonNames());
        unitPanel.updateChecks(getUnitNames());
        agencyPanel.updateChecks(getAgencyNames());
    }
    
    function updateDisplay() {
        display.update(filtered);
    }
}

/**
 * @param target
 *                may be a selector or a JQuery selection. Get the element
 *                either way, so we know what we are working with.
 */
function GrantsDisplay(target, legendSelector) {
    var targetElem = $(target).get(0);

    var height = Math.floor($(targetElem).height());
    var width = Math.floor($(targetElem).width());

    var fillColor = d3.scale.ordinal()
        .domain(['unknown','low', 'medium', 'high'])
        .range(["#41B3A7","#81F7F3", "#819FF7", "#BE81F7"]);

    var force = d3.layout.force()
        .size([width, height])
        .charge(charge)
        .gravity(-0.01)
        .friction(0.9);

    //Used when setting up force and moving around nodes
    var damper = 0.102;

    //tooltip for mouseover functionality
    var tooltip = GrantsTooltip("grants_tooltip", 400);
    
    function charge(d) {
        return -Math.pow(d.radius, 2.0) / 8;
    }

    return {
        clear: clear,
        draw: draw,
        update: draw  // BOGUS
    }
    
    function clear() {
        d3.select(targetElem).select("svg").remove();
    }
    
    function draw(rawData) {
        clear();
        tooltip.hideTooltip();

        drawLegend();

        var nodes = createGrantNodes(rawData);
        force.nodes(nodes);
        
        var svg = d3.select(targetElem)
            .append('svg')
            .attr('width', width)
            .attr('height', height);
        
        // Bind nodes data to what will become DOM elements to represent them.
        var bubbles = svg.selectAll('.bubble').data(nodes, d => d.id );

        // Create new circle elements each with class `bubble`.
        // There will be one circle.bubble for each object in the nodes array.
        // Initially, their radius (r attribute) will be 0.
        bubbles
            .enter()
            .append('circle')
            .classed('bubble', true)
            .attr('r', 0)
            .attr('fill', d => fillColor(d.group))
            .attr('stroke', d => d3.rgb(fillColor(d.group)).darker())
            .attr('stroke-width', 2)
            .on('mouseover', hoverOverBubble)
            .on('mouseout', leaveBubble)
            .on('click', clickOnBubble);

        // Fancy transition to make bubbles appear, ending with the correct radius
        bubbles.transition()
            .duration(500)
            .attr('r', d => d.radius);

        groupBubbles();

        function drawLegend() {
            var legend = d3.select(legendSelector)
                .append("svg")
                .attr("width", 300)
                .attr("height", 300);
            legend
                .append('text')
                .attr('x',5)
                .attr('y', 12)
                .style("font-weight", "bold")
                .style("margin-bottom","20px")
                .text("Color Scheme");
            fillColor
                .range()
                .forEach(drawLegendBar);
            
            function drawLegendBar(color, i) {
                var domainValues = ["Unknown", "< $100,000", "$100,000 - $1,000,000", "> $1,000,000"];
                legend
                    .append('rect')
                    .attr("width", 20)
                    .attr("height", 20)
                    .attr("x", 5)
                    .attr("y", 25 + i*25)
                    .style("fill", color);
                legend
                    .append('text')
                    .attr("x", 42)
                    .attr("y", 20 + 20 + i*25)
                    .attr("alignment-baseline", "hanging")
                    .attr("text-anchor", "start")
                    .style("font-size", 16)
                    .text(domainValues[i]);
            }
        }
        
        function createGrantNodes(data) {
            var radiusScaler = createRadiusScaler();
            return data.map(nodeBuilder).sort(nodeSorter);

            function createRadiusScaler() {
                //Sizes bubbles based on their area instead of raw radius
                return d3.scale.pow()
                    .exponent(0.5)
                    .range([2, 15])
                    .domain([0, d3.max(data, d => +d.Cost)]); 
            }
            
            function nodeBuilder(d) {
                return {
                    id: d.id,
                    radius: radiusScaler(+d.Cost),
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
            }
            
            // sort them to prevent occlusion of smaller nodes.
            function nodeSorter(a, b) { 
                return b.value - a.value; 
            }
            
        } 
        
        function groupBubbles() {
            force.on('tick', function (e) {
                bubbles.each(moveToCenter(e.alpha))
                    .attr('cx', d => d.x)
                    .attr('cy', d => d.y);
            });
            force.start();
            
            function moveToCenter(alpha) {
                return function (d) {
                    d.x = d.x + (width / 2 - d.x) * damper * alpha;
                    d.y = d.y + (height / 2 - d.y) * damper * alpha;
                };
            }
        }
        
        function hoverOverBubble(data) {
            addHighlight(this);
            tooltip.showName(data)
        }
        
        function clickOnBubble(data) {
            tooltip.showDetails(data);
        }
        
        function leaveBubble(data) {
            removeHighlight(this, data);
            tooltip.hideName();
        }
        
        function addHighlight(bubble) {
            d3.select(bubble).attr('stroke', 'black');
        }
        
        function removeHighlight(bubble, data) {
            if (data && ('group' in data)) {
                d3.select(bubble).attr('stroke', d3.rgb(fillColor(data.group)).darker());
            }
        }
    }
}

