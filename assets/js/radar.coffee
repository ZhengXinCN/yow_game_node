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
  add_circle: (circle) ->
    @max_radius = circle.radius if @max_radius < circle.radius

    drawn_circle = circle.draw_circle(@x,@y)
    @layer.add(drawn_circle)

    circle.draw_label(@x, @y, @foregroundLayer)

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
