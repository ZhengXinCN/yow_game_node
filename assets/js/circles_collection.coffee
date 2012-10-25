class CirclesCollection
  if require?
    {Circle} = require './circle'
  else
    Circle = window.Circle
  constructor: (x,y) ->
    @circles = []
    @circles.push @trial_circle = new Circle {radius:205, label:"TRIAL", x:x, y:y}
    @circles.push @hold_circle = new Circle {radius:300, label:"HOLD", x:x, y:y}
    @circles.push @assess_circle = new Circle {radius:250, label:"ASSESS", x:x ,y:y, double: true}
    @circles.push @adopt_circle = new Circle {radius:110, label:"ADOPT", x:x, y:y}

  hit_circle:(x,y) ->
    circles_sorted = @circles.sort (a,b)->
      a.radius - b.radius
    for circle in circles_sorted
      if circle.is_inside_circle x,y
        hit_circle = circle
        break
    hit_circle

if module? and module.exports?
  module.exports.CirclesCollection = CirclesCollection
else window.CirclesCollection = CirclesCollection
