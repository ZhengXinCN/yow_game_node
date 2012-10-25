class @Radar
  kBoardWidth = window.innerWidth
  kBoardHeight = window.innerHeight
  kCircleRadius = 15
  kAccelerationSensitivity = 1.5
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
    
    @textLayer = new Kinetic.Layer()
    @stage.add @textLayer
    
    @boardLayer = new Kinetic.Layer()
    @stage.add @boardLayer

    piece =
      center:
        x: kBoardWidth / 2
        y: kBoardHeight / 2
        xShift: 0
        yShift: 0
      ,
      color: 'lightBlue'

    
    window.addEventListener "devicemotion", (event) =>
       accel = event.accelerationIncludingGravity
       piece.center = @computeCenter(piece.center, accel)
       console.log piece
       if piece.center.x > 330 - 25 && piece.center.x < 330 + 25 && piece.center.y < 600 + 25 && piece.center.y > 600 - 25
         piece.color = 'red'
       else
         piece.color = 'lightBlue'
       @drawPiece(@boardLayer.getContext(), piece)

    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @max_radius = 0

  add_circles: (circles_collection) ->
    @circles_collection = circles_collection
    circles_collection.circles.forEach (circle) =>
      @max_radius = circle.radius if @max_radius < circle.radius
      circle.draw_circle(@layer)
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

  message_for_hit: (e) =>
    if e.x
      hitted_circle = @circles_collection.hit_circle(e.x, e.y)
    else
      hitted_circle = @circles_collection.hit_circle(e.changedTouches[0].screenX, e.changedTouches[0].screenY)
    @textLayer.removeChildren()
    if hitted_circle
      textOps =
        x: 0,
        y: 40
        text: "Technology is in #{hitted_circle.label}",
        fontSize: 14,
        fontFamily: "Calibri",
        textFill: "green"

      simpleText = new Kinetic.Text textOps
      @textLayer.add(simpleText)
      @textLayer.draw()

  generate_technologies: (technologies)->
    technology_layer = new Kinetic.Layer()
    technology = new Kinetic.Circle
          radius: 25,
          stroke: 'black',
          fill: 'black',
          strokeWidth: 1,
          x: 330
          y: 600,
      technology_layer.add(technology)
      @stage.add technology_layer

  computeCenter: (oldCenter, acceleration) ->
    newCenter = {}
    newCenter.xShift = oldCenter.xShift * 0.8 + acceleration.x * kAccelerationSensitivity
    newCenter.yShift = oldCenter.yShift * 0.8 + acceleration.y * kAccelerationSensitivity
    newCenter.x = oldCenter.x + oldCenter.xShift
    
    # use *minus* to compute the center's new y
    newCenter.y = oldCenter.y - oldCenter.yShift
    
    # do not go outside the boundaries of the canvas
    newCenter.x = kCircleRadius  if newCenter.x < kCircleRadius
    newCenter.x = kBoardWidth - kCircleRadius  if newCenter.x > kBoardWidth - kCircleRadius
    newCenter.y = kCircleRadius  if newCenter.y < kCircleRadius
    newCenter.y = kBoardHeight - kCircleRadius  if newCenter.y > kBoardHeight - kCircleRadius
    newCenter

  drawPiece: (context, piece) ->

    #Store the current transformation matrix
    context.save()

    #Use the identity matrix while clearing the canvas
    context.setTransform(1, 0, 0, 1, 0, 0)
    context.clearRect(0, 0, kBoardWidth, kBoardHeight)

    #Restore the transform
    context.restore()
    context.fillStyle = piece.color
    context.beginPath()
    context.arc piece.center.x, piece.center.y, kCircleRadius, 0, Math.PI * 2, false
    context.closePath()
    context.fill()
