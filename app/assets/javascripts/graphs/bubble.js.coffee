Visio.Graphs.bubble = (config) ->

  margin = config.margin

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection

  duration = 500

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  x = d3.scale.linear()
    .range([0, width])

  y = d3.scale.linear()
    .domain([0, 1])
    .range([height, 0])

  r = d3.scale.sqrt()
    .domain([0, 1000000])
    .range([0, 20])

  domain = null

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')
    .tickFormat(d3.format('s'))
    .ticks(6)
    .innerTickSize(14)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .ticks(5)
    .tickFormat((d) -> return if d then d * 100 else '0%')
    .innerTickSize(14)
    .tickPadding(20)

  parameters = config.parameters || []

  info = new Visio.Views.BubbleInfoView({
    el: $('.info-container .bubble-info')
  })

  voronoi = d3.geom.voronoi()
    .clipExtent([[0, 0], [width, height]])
    .x((d) -> x(d.budget))
    .y((d) -> y(d.achievement))

  g.append('g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(0,0)')
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0)
      .attr("x", -height)
      .attr("dy", "-.21em")
      .style("text-anchor", "start")
      .text('Acheivement')

  g.append('g')
    .attr('class', 'x axis')
    .attr('transform', "translate(0,#{height})")
    .append("text")
      .attr("x", width + 10)
      .attr("dy", "-.21em")
      .style("text-anchor", "start")
      .text('Budget')

  render = () ->

    maxBudget = 0

    data = parameters.map (parameter) ->
      achievement = parameter.selectedAchievement().result
      iso = if parameter.get('country') then parameter.get('country').iso3 else null
      datum = {
        id: parameter.get('id')
        name: parameter.toString()
        iso: iso
        budget: parameter.selectedBudget()
        achievement: achievement
        population: Math.random() * 1000000
      }
      maxBudget = datum.budget if datum.budget > maxBudget
      return datum

    data = data.filter (d) ->
      return d.budget && d.achievement

    if !domain || domain[1] < maxBudget || domain[1] > 2 * maxBudget
      domain = [0, maxBudget]
      x.domain(domain)

    bubbles = g.selectAll('.bubble')
      .data(data, (d) -> d.iso || d.id)

    bubbles.enter().append('circle')
    bubbles
      .attr('class', (d) ->
        return ['bubble'].join(' '))

    bubbles
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('r', (d) ->
        return r(50000))
      .attr('cy', (d) ->
        return y(d.achievement))
      .attr('cx', (d) ->
        return x(d.budget))

    bubbles.exit().remove()

    path = g.selectAll('.voronoi')
      .data(voronoi(data))


    path.enter().append("path")
    path.attr("class", (d, i) -> "voronoi" )
        .attr("d", polygon)
        .on('mouseenter', (d) ->
          info.render(d.point)
          info.show()
        )

    path.exit().remove()

    g.select('.x.axis')
      .transition()
      .delay(duration)
      .duration(duration)
      .call(xAxis)

    g.select('.y.axis')
      .transition()
      .duration(duration)
      .call(yAxis)
      .attr('transform', 'translate(-20,0)')

  polygon = (d) ->
    "M" + d.join("L") + "Z"

  render.parameters = (_parameters) ->
    return parameters unless arguments.length
    parameters = _parameters
    return render

  render.width = (_width) ->
    return width unless arguments.length
    width = _width
    return render

  return render


