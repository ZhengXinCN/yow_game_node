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

    @shape = new Kinetic.Group
      x: @piece.center.x
      y: @piece.center.y
    @shape.add new Kinetic.Circle
      radius: 15
      fill: "#298EC3"
    @shape.add new Kinetic.Circle
      radius: 15
      stroke: "white"
      strokeWidth: 2

    @layer.add @shape

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

  detect_motion:(boardLayer) ->
    eventID = 0
    window.addEventListener "devicemotion", (event) =>
      accel = event.accelerationIncludingGravity
      eventID = eventID + 1
      if( eventID %100 == 0)
        console.log(event)

      @piece.center = @computeCenter(@piece.center, accel)
      @piece.color = '#298EC3'
      @drawPiece()


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
