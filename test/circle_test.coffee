
{Circle} = require '../assets/js/circle'

describe 'Circle', ->
  before ->
    @circle = new Circle
           radius:15
           x:5
           y:0
  it 'detect that object is in circle if it is inside x axis', ->
    is_inside = @circle.is_inside_circle(-5,0)
    is_inside.should.equal true
  it 'detect that object is in circle if it is inside y axis', ->
    is_inside = @circle.is_inside_circle(0,-14)
    is_inside.should.equal true
  describe 'outside of borders detection', ->
    it 'detects that object is not in circle if it is outside of right part of the circle', ->
      is_inside = @circle.is_inside_circle(25,0)
      is_inside.should.equal false
    it 'detects that object is not in circle if it is outside of left part of the circle', ->
      is_inside = @circle.is_inside_circle(-25,0)
      is_inside.should.equal false
    it 'detects that object is not in circle if it is on the border', ->
      is_inside = @circle.is_inside_circle(20,0)
      is_inside.should.equal false
