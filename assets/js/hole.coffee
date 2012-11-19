define ['q','kinetic', 'sylvester'], (Q,Kinetic)->
  class Hole
    constructor: (opts)->
      @layer = opts.layer
      @hole_radius = opts.hole_radius
      @hole = new Kinetic.Circle
        radius: @hole_radius
        stroke: "black"
        strokeWidth: 1
        fill: "black"
        x: opts.x
        y: opts.y

      @obstacle =  new Kinetic.Circle
        radius: 20
        fill: "red"
        x: @hole.getX()
        y: @hole.getY()
      @obstacle.delta = $V([0,0])
      @amplitude = 50
      @period = 2000

    play: ->
      @layer.add @hole
      @layer.add @obstacle
      @anim = new Kinetic.Animation
        func: (frame) =>
          @update(frame)
        node: @layer
      .start()
      Q.defer().promise

    complete: ->
      @obstacle.remove()
      @anim?.stop()

      # @hole.setFill ("blue")
      @hole.moveToBottom()
      @hole.transitionTo
        opacity: 0.2
        radius: @hole_radius - 5
        duration: 0.5

      this

    update: (frame) ->
      start = $V([@obstacle.getX(), @obstacle.getY()])

      @obstacle.setX @amplitude * Math.sin(frame.time * 2 * Math.PI / @period) + @hole.getX()
      @obstacle.setY @amplitude * Math.cos(frame.time * 2 * Math.PI / @period) + @hole.getY()

      @obstacle.delta = $V([@obstacle.getX(),@obstacle.getY()]).subtract(start)