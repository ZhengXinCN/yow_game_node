class Marble
  kCircleRadius = 15
  kAccelerationSensitivity = 1.5


  constructor: (opts)->
    @text = opts.label
    @layer = opts.layer
    @board = opts.board
    @piece =
      center:
        x: @board.width / 2
        y: @board.height / 2
        xShift: 0
        yShift: 0
      color: '#298EC3'
    @marble_radius = 15
    @shape = new Kinetic.Group
      x: @piece.center.x
      y: @piece.center.y
    @shape.add new Kinetic.Circle
      radius: @marble_radius
      fill: "red"
    @shape.add new Kinetic.Circle
      radius: @marble_radius
      stroke: "white"
      strokeWidth: 2

    @layer.add @shape

    @hole = opts.hole.hole
    @obstacle = opts.hole.obstacle

    @label = new Kinetic.Text
      x: @piece.center.x
      y: @piece.center.y
      fontSize: 13
      fontFamily: "Helvetica"
      fontStroke: "black"
      textFill: "black"
      textStrokeWidth: 1
      text: @text

    @layer.add @label

  detect_motion: ->
    window.addEventListener "devicemotion", (event) =>
      accel = event.accelerationIncludingGravity

      @piece.center = @computeCenter(@piece.center, accel)
      @piece.color = '#298EC3'
      if @detect_hole_collision()
        console.log "collision"

      if @detect_obstacle_collision()
        @obstacle.setFill("green")
        console.log "obstacle collision"
      @drawPiece()

  detect_obstacle_collision: ->

    console.log @obstacle
    x_diff = @piece.center.x - @obstacle.getX()
    y_diff = @piece.center.y - @obstacle.getY()
    actual_distance = Math.sqrt(x_diff * x_diff + y_diff * y_diff)
    sum_of_radius = @marble_radius + @obstacle.getRadius()
    actual_distance < sum_of_radius

  detect_hole_collision: ->
    x_diff = @piece.center.x - @hole.getX()
    y_diff = @piece.center.y - @hole.getY()
    actual_distance = Math.sqrt(x_diff * x_diff + y_diff * y_diff)
    sum_of_radius = 15 + @hole.getRadius()
    actual_distance < sum_of_radius

  computeCenter: (oldCenter, acceleration) ->
    newCenter = {}
    newCenter.xShift = oldCenter.xShift * 0.8 + (acceleration.y * kAccelerationSensitivity)
    newCenter.yShift = oldCenter.yShift * 0.8 - (acceleration.x * kAccelerationSensitivity)
    newCenter.x = oldCenter.x + oldCenter.xShift

    # use *minus* to compute the center's new y
    newCenter.y = oldCenter.y - oldCenter.yShift

    # do not go outside the boundaries of the canvas
    newCenter.x = kCircleRadius  if newCenter.x < kCircleRadius
    newCenter.x = @board.width - kCircleRadius  if newCenter.x > @board.width - kCircleRadius
    newCenter.y = kCircleRadius  if newCenter.y < kCircleRadius
    newCenter.y = @board.height - kCircleRadius  if newCenter.y > @board.height - kCircleRadius
    newCenter


  drawPiece: ->
    @shape.setPosition(@piece.center.x, @piece.center.y)
    @label.setPosition(@piece.center.x - @label.getTextWidth() / 2, @piece.center.y - kCircleRadius - @label.getTextHeight() - 5);
    @layer.draw()

if module? and module.exports?
  module.exports.Marble = Marble
else window.Marble = Marble
