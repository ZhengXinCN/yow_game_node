class Marble
  kBoardWidth = window.innerWidth
  kBoardHeight = window.innerHeight
  kCircleRadius = 15
  kAccelerationSensitivity = 1.5

  piece =
    center:
      x: kBoardWidth / 2
      y: kBoardHeight / 2
      xShift: 0
      yShift: 0
    ,
    color: '#298EC3'

  constructor: (label)->
    @label = label

  detect_motion:(boardLayer) ->
    window.addEventListener "devicemotion", (event) =>
      accel = event.accelerationIncludingGravity
      piece.center = @computeCenter(piece.center, accel)
      piece.color = '#298EC3'
      @drawPiece(boardLayer.getContext(), piece)


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
    width_of_text = context.measureText(@label).width
    context.lineWidth = 1
    context.font="13pt Helvetica"
    context.strokeText(@label, piece.center.x - width_of_text / 2, piece.center.y - kCircleRadius - 5);
    context.fillStyle = piece.color
    context.beginPath()
    context.arc piece.center.x, piece.center.y, kCircleRadius, 0, Math.PI * 2, false
    context.closePath()
    context.fill()


if module? and module.exports?
  module.exports.Marble = Marble
else window.Marble = Marble
