class Hole

  constructor:  ({center_x,center_y}) ->
    @center_x = center_x
    @center_y = center_y
    @radius = 20

  draw_hole: (layer) =>
    opts =
      radius: @radius
      fill: 'black'
      x: @center_x
      y: @center_y
    hole = new Kinetic.Circle opts
    layer.add(hole)
