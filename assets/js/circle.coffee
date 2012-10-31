class Circle
  constructor: ({ radius, label, x, y, double}) ->
    @radius = radius
    @label = label
    @x = x
    @y = y
    @double = double

  draw_circle: (layer) =>
    opts =
      radius: @radius
      stroke: '#A2A5A4'
      strokeWidth: 1
      x: @x
      y: @y
    circle = new Kinetic.Circle opts
    layer.add(circle)
    if @double
      opts['radius']  = opts['radius'] + 5
      circle = new Kinetic.Circle opts
      layer.add(circle)

  draw_label: (x,y, labelLayer) ->
    if @label
      @draw_text_along_arc(labelLayer.getContext(), @label, x, y, @radius - 5, 20 * (Math.PI / 180))

  draw_text_along_arc: (context, str, centerX, centerY, radius, angle) ->
    context.save()
    angle = angle - radius* 0.001 + 0.8
    context.translate(centerX, centerY)
    context.rotate(-0.2 * angle / 2)
    context.rotate(-0.2 * (angle / str.length) / 2)
    n = 0
    while n < str.length
        context.rotate( angle / str.length)
        context.save()
        context.translate(0, -1 * radius)
        char = str[n]
        #context.fillText(char, 0, 0)
        context.font = "15pt Calibri"
        context.strokeStyle= "#A2A5A4"
        context.lineWidth = 2
        context.strokeText(char, 0, 0)
        context.restore()
        n++
    context.restore()
  is_inside_circle: (x,y) ->
      xFromCenter = x - @x
      yFromCenter = y - @y
      radiusFromCenterToObject = Math.sqrt(Math.pow(xFromCenter, 2) + Math.pow(yFromCenter, 2))
      @radius > radiusFromCenterToObject

if module? and module.exports?
  module.exports.Circle = Circle
else window.Circle = Circle

