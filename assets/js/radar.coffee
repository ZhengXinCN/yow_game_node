class @Radar
  constructor: ->
    @canvas = document.getElementById("myCanvas")
    @context = @canvas.getContext("2d")
    @context.canvas.width  = window.innerWidth
    @context.canvas.height = window.innerHeight
    @x = @canvas.width / 2
    @y = @canvas.height / 2
    @max_radius = 0
  draw_circle: (radius) ->
    @max_radius = radius if @max_radius < radius
    startAngle = 0
    endAngle = 2 * Math.PI
    counterClockwise = false

    @context.beginPath()

    @context.arc(@x, @y, radius, startAngle, endAngle, counterClockwise)
    @context.lineWidth = 2
    # line color
    @context.strokeStyle = "white"
    @context.stroke()

  draw_horizontal_line: (extends_over_circle) ->
    @context.beginPath()
    @context.lineWidth = 1
    @context.moveTo(@x - @max_radius - extends_over_circle, @y)
    @context.lineTo(@x + @max_radius + extends_over_circle, @y)
    @context.stroke()

   draw_vertical_line: (extends_over_circle) ->
     @context.beginPath()
     @context.lineWidth = 1
     @context.moveTo(@x, @y - @max_radius - extends_over_circle)
     @context.lineTo(@x, @y + @max_radius + extends_over_circle)
     @context.stroke()
