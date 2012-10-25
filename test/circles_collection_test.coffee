{CirclesCollection} = require '../assets/js/circles_collection'
describe 'CirclesCollection', ->
  before ->
    @circles_collection = new CirclesCollection(0,0)

  it 'detects hit for adopt ring if hit inside it', ->
    circle = @circles_collection.hit_circle(@circles_collection.adopt_circle.x - 10, @circles_collection.adopt_circle.y - 10)
    circle.should.equal @circles_collection.adopt_circle
