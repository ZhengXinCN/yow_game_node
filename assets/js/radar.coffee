class @Radar
  constructor: ->
    @stage = new Kinetic.Stage
          container: 'container',
          width: window.innerWidth,
          height: window.innerHeight
    @layer = new Kinetic.Layer()

    @foregroundLayer = new Kinetic.Layer()
    $(@foregroundLayer.canvas.element).addClass("foreground")
    @stage.add @foregroundLayer

    @backgroundLayer = new Kinetic.Layer()
    @stage.add @backgroundLayer

    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @max_radius = 0
  add_circle: (radius, circle_name) ->
    @max_radius = radius if @max_radius < radius
    circle = new Kinetic.Circle
          radius: radius,
          stroke: 'white',
          strokeWidth: 1,
          x: @x,
          y: @y
    @layer.add(circle)
    startAngle = 0
    endAngle = 2 * Math.PI
    counterClockwise = false
    if circle_name
      @draw_text_along_arc(@foregroundLayer.getContext(), circle_name, @x, @y, radius - 5, 50 * (Math.PI / 180))


  draw_horizontal_line: (extends_over_circle) ->
    context = @backgroundLayer.getContext()

    context.beginPath()
    context.lineWidth = 1
    context.strokeStyle = "white"
    context.moveTo(@x - @max_radius - extends_over_circle, @y)
    context.lineTo(@x + @max_radius + extends_over_circle, @y)
    context.stroke()

  draw_vertical_line: (extends_over_circle) ->
    context = @backgroundLayer.getContext()

    context.beginPath()
    context.strokeStyle = "white"
    context.lineWidth = 1
    context.moveTo(@x, @y - @max_radius - extends_over_circle)
    context.lineTo(@x, @y + @max_radius + extends_over_circle)
    context.stroke()

  draw_main_layer: ->
    @stage.add @layer

  generate_technologies: ->
    circle_layer = new Kinetic.Layer()
    for num in [1..10]
      circle = new Kinetic.Circle
            radius: 15,
            stroke: 'black',
            fill: 'lightBlue',
            strokeWidth: 1,
            x: 25 * num * 1.5,
            y: 25,
            draggable: true
      circle.on "dragend", (e) =>
        console.log e
        x = e.x - @x
        y = e.y - @y
        console.log (x)
        console.log (y)
        console.log "Radius #{Math.sqrt(x*x + y*y)}"
      circle_layer.add(circle)
    @stage.add circle_layer
  draw_text_along_arc: (context, str, centerX, centerY, radius, angle) ->
    context.save()

    context.translate(centerX, centerY)
    context.rotate(-1 * angle / 2)
    context.rotate(-1 * (angle / str.length) / 2)
    n = 0
    while n < str.length
        context.rotate(angle / str.length)
        context.save()
        context.translate(0, -1 * radius)
        char = str[n]
        #context.fillText(char, 0, 0)
        context.font = "15pt Calibri"
        context.lineWidth = 2
        context.strokeText(char, 0, 0)
        context.restore()
        n++
    context.restore()
