class @Radar
  constructor: ->
    @stage = new Kinetic.Stage
          container: 'container',
          width: window.innerWidth,
          height: window.innerHeight
    @layer = new Kinetic.Layer()
    @backgroundLayer = new Kinetic.Layer()
    @stage.add @backgroundLayer
    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @max_radius = 0
  add_circle: (radius) ->
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
