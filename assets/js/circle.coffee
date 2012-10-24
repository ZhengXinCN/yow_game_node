class @Circle
  constructor: (radius, label) ->
    @radius = radius
    @label = label

  draw_circle: (x,y) ->
    circle = new Kinetic.Circle
          radius: @radius,
          stroke: 'white',
          strokeWidth: 1,
          x: x,
          y: y

  draw_label: (x,y, labelLayer) ->
    if @label
      @draw_text_along_arc(labelLayer.getContext(), @label, x, y, @radius - 5, 50 * (Math.PI / 180))
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
