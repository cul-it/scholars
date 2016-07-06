
class BubbleChart
  constructor: (data) ->
    @data = data
    @width = 900
    @height = 600
    @currentlyClicked = false

    @years = []
    @depts = []
    @funagens = []
    @pis = []

    for item in @data
      if item.Start not in @years
        @years.push(item.Start)
      if item.dept.name not in @depts
        @depts.push(item.dept.name)
      if item.funagen.name not in @funagens
        @funagens.push(item.funagen.name)
      for person in item.people
        if person.name not in @pis
          @pis.push(person.name)


    @years.sort();
    @years.reverse();
    @depts.sort()
    @funagens.sort()
    @pis.sort()

    for year in @years
      $("#years").append($("<option name='" + year + "'>" + year + "</option>"))
    for dept in @depts
      $("#depts").append($("<option name='" + dept + "'>" + dept + "</option>"))
    for funagen in @funagens
      $("#funagens").append($("<option name='" + funagen + "'>" + funagen + "</option>"))
    for pi in @pis
      $("#pis").append($("<option name='" + pi + "'>" + pi + "</option>"))

    @tooltip = CustomTooltip("gates_tooltip", 400)

    # locations the nodes will move towards
    # depending on which view is currently being
    # used
    @center = {x: @width / 2, y: @height / 2}

    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.01
    @damper = 0.1

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @force = null
    @circles = null

    # nice looking colors - no reason to buck the trend
    @fill_color = d3.scale.ordinal()
      .domain(["unknown","low", "medium", "high"])
      .range(["#41B3A7","#81F7F3", "#819FF7", "#BE81F7"])

    # use the max total_amount in the data as the max in the scale's domain
    max_amount = d3.max(@data, (d) -> parseInt(d.Cost))
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_amount]).range([2, 20])
    
    default_year = @years[0]
    @setup_year_centers(default_year)
    default_dept = @depts[0]
    @setup_dept_centers(default_dept)
    default_funagen = @funagens[0]
    @setup_funagen_centers(default_funagen)
    default_pi = @pis[0]
    @setup_pi_centers(default_pi)

    this.create_nodes()
    this.create_vis()

    @vis.on("click", () =>
      @tooltip.hideTooltip()
      @currentlyClicked = false
    )

  setup_year_centers: (currentYear) =>
    @year_centers = {}
    for year in @years
      # place the centers off the canvas
      @year_centers[''+year] = {x: @width + 500, y: @height + 500}
    @year_centers[''+currentYear] = {x: @width / 2, y: @height / 2}

  setup_dept_centers: (currentDept) =>
    @dept_centers = {}
    for dept in @depts
      # place the centers off the canvas
      @dept_centers[dept] = {x: @width + 500, y: @height + 500}
    @dept_centers[currentDept] = {x: @width / 2, y: @height / 2}

  setup_funagen_centers: (currentFunagen) =>
    @funagen_centers = {}
    for funagen in @funagens
      # place the centers off the canvas
      @funagen_centers[funagen] = {x: @width + 500, y: @height + 500}
    @funagen_centers[currentFunagen] = {x: @width / 2, y: @height / 2}

  setup_pi_centers: (currentPI) =>
    @pi_centers = {}
    for pi in @pis
      # place the centers off the canvas
      @pi_centers[pi] = {x: @width + 500, y: @height + 500}
    @pi_centers[currentPI] = {x: @width / 2, y: @height / 2}

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.id
        radius: @radius_scale(parseInt(d.Cost))
        value: d.Cost
        dept: d.dept
        name: d.grant.title
        group: d.group
        year: d.Start
        url: d.grant.uri
        grant: d.grant
        people: d.people
        funagen: d.funagen
        x: Math.random() * 900
        y: Math.random() * 800
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value


  # create svg at #vis and then 
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the 
    # mouse callbacks
    that = this

    # radius will be set to 0 initially.
    # see transition below
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_color(d.group))
      .attr("stroke-width", 2)
      .attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
      .attr("Id", (d) -> "bubble_#{d.id}")
      .on("mouseover", (d,i) -> 
        that.show_details(d,i,this)
      ).on("mouseout", (d, i) ->
        that.hide_details(d, i, this)
      ).on("click", (d, i) ->
        that.make_details_clickable(d, i, this)
        d3.event.stopPropagation();
      )

    # Fancy transition to make bubbles appear, ending with the
    # correct radius
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)


  # Charge function that is called for each node.
  # Charge is proportional to the diameter of the
  # circle (which is stored in the radius attribute
  # of the circle's associated data.
  # This is done to allow for accurate collision 
  # detection with nodes of different sizes.
  # Charge is negative because we want nodes to 
  # repel.
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 8

  # Starts up the force layout with
  # the default values
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display
  # all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_years()
    this.hide_dept()
    this.hide_funagen()
    this.hide_pi()
    @tooltip.hideTooltip()
    @currentlyClicked = false

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  # sets the display of bubbles to be separated
  # into each year. Does this by calling move_towards_year
  display_by_year: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_year(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_dept()
    this.hide_funagen()
    this.hide_pi()
    @tooltip.hideTooltip()
    @currentlyClicked = false
    this.display_years()

  display_by_dept: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_dept(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_years()
    this.hide_funagen()
    this.hide_pi()
    @tooltip.hideTooltip()
    @currentlyClicked = false
    this.display_dept()

  display_by_funagen: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_funagen(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_years()
    this.hide_dept()
    this.hide_pi()
    @tooltip.hideTooltip()
    @currentlyClicked = false
    this.display_funagen()

  display_by_pi: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_pi(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_years()
    this.hide_dept()
    this.hide_funagen()
    @tooltip.hideTooltip()
    @currentlyClicked = false
    this.display_pi()



  # move all circles to their associated @year_centers 
  move_towards_year: (alpha) =>
    (d) =>
      target = @year_centers[d.year]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  move_towards_dept: (alpha) =>
    (d) =>
      target = @dept_centers[d.dept.name]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  move_towards_funagen: (alpha) =>
    (d) =>
      target = @funagen_centers[d.funagen.name]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  move_towards_pi: (alpha) =>
    (d) =>
      target = @pi_centers[d.person.name]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  display_years: () =>
    $("#years-container").show()

  # Method to hide year titiles
  hide_years: () =>
    $("#years-container").hide()
  
  display_dept: () =>
    $("#depts-container").show()


  # Method to hide dept titiles
  hide_dept: () =>
    $("#depts-container").hide()

  display_funagen: () =>
    $("#funagens-container").show()

  # Method to hide dept titiles
  hide_funagen: () =>
    $("#funagens-container").hide()

  display_pi: () =>
    $("#pis-container").show()

  # Method to hide dept titiles
  hide_pi: () =>
    $("#pis-container").hide()


  show_details: (data, i, element) =>
    if not @currentlyClicked
      d3.select(element).attr("stroke", "black")
      content = "<span class=\"name\"></span><span class=\"value\">#{data.name}</span><br/>"
      @tooltip.showTooltip(content,d3.event)

  make_details_clickable: (data, i, element) =>
    @currentlyClicked = true
    @tooltip.hideTooltip()
    content = "<span class=\"name\">Title:</span><span class=\"value\"><a href='#{data.grant.uri}'>#{data.name}</a></span><br/>"
    content += this.format_people(data.people)
    content +="<span class=\"name\">Department:</span><span class=\"value\"><a href='#{data.dept.uri}'>#{data.dept.name}</a></span><br/>"
   #content +="<span class=\"name\">Amount:</span><span class=\"value\"> $#{addCommas(data.value)}</span><br/>"
    content +="<span class=\"name\">Funding agency:</span><span class=\"value\"><a href='#{data.funagen.uri}'>#{data.funagen.name}</a></span><br/>"
    content +="<span class=\"name\">Year:</span><span class=\"value\"> #{data.year}</span>"
    @tooltip.showTooltip(content,d3.event)
    
  format_people: (people) =>
    people.sort (a,b) ->
      if a.role > b.role then -1 else if a.role < b.role then 1 else 0
    spans = for p in people
      this.format_person(p)
    spans.join("")

  format_person: (p) =>
    if p.role is "PI"
      role = "Investigator"
    else
      role = "Co-Investigator"
    "<span class=\"name\">#{role}:</span><span class=\"value\"><a href='#{p.uri}'>#{p.name}</a></span><br/>"
  
  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
    #@tooltip.hideTooltip()


root = exports ? this

$ ->
  chart = null

  render_vis = (json) ->
    chart = new BubbleChart json
    chart.start()
    root.display_all()
  
  root.display_all = () =>
    chart.display_group_all()
  
  root.display_year = () =>
    chart.display_by_year()
    $("#years").change((e) =>
      chart.setup_year_centers($("#years").val())
      chart.display_by_year()
    )

  root.display_dept = () =>
    chart.display_by_dept()
    $("#depts").change((e) =>
      chart.setup_dept_centers($("#depts").val())
      chart.display_by_dept()
    )
  
  root.display_funagen = () =>
    chart.display_by_funagen()
    $("#funagens").change((e) =>
      chart.setup_funagen_centers($("#funagens").val())
      chart.display_by_funagen()
    )

  root.display_pi = () =>
    chart.display_by_pi()
    $("#pis").change((e) =>
      chart.setup_pi_centers($("#pis").val())
      chart.display_by_pi()
    )

  root.toggle_view = (view_type) =>
    if view_type == 'year'
      root.display_year()
    else if view_type == 'dept'
      root.display_dept()
    else if view_type == 'funagen'
      root.display_funagen()
    else if view_type == 'pi'
      root.display_pi()
    else
      root.display_all()

  loadVisualization {
#     target : '#bogus',
      url : applicationContextPath + "/api/dataRequest/grants_bubble_chart",
      transform : transformGrantsData,
      display : render_vis,
      height : 600,
      width : 700
     }
  
  
