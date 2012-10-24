
{Circle} = require '../assets/js/circle'

describe 'Circle', ->
  before ->
    @circle = new Circle
           radius:15
           x:5
           y:0
  it 'detect that object is in circle if it is inside', ->
    is_inside = @circle.is_inside_circle(10,5)
    is_inside.should.equal true
  it 'decect that object is not in circle if it is outside of borders', ->
    is_inside = @circle.is_inside_circle(25,10)
    is_inside.should.equal false
  it 'detect that object is not in circle if it is on the border', ->
    is_inside = @circle.is_inside_circle(20,0)
    is_inside.should.equal false
