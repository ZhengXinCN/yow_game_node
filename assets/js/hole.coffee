define ['kinetic'], (Kinetic)->
  class Hole
    constructor: (opts)->
      @layer = opts.layer
      @quadrant = opts.quadrant
      @ring = opts.ring.outer
      @inner_ring =opts.ring.inner
      @hole_radius = opts.hole_radius

      @random_var = Math.random()
      @center_x = opts.center_x
      @center_y = opts.center_y

      @hole = new Kinetic.Circle
        radius: @hole_radius
        stroke: "black"
        strokeWidth: 1
        fill: "black"

      @obstacle =  new Kinetic.Circle
        radius: 20
        fill: "yellow"
        x: @hole.getX()
        y: @hole.getY()


    play: ->
      @layer.add @obstacle
      @draw_hole()
      new $.Deferred

    complete: ->
      @hole.remove()
      @obstacle.remove()
      @layer.draw()
      true


    draw_hole: ->
      @random_radius = @compute_random_radius()
      @angle = @compute_angle()
      @hole.setX  @center_x + @random_radius * Math.sin(@angle)
      @hole.setY  @center_y + @random_radius * Math.cos(@angle)
      @layer.add @hole
      @generate_obstacle()
      @layer.draw()

    compute_angle: ->
      pi = Math.PI
      angle_var = Math.asin(@hole_radius / @random_radius)
      random_angle = angle_var + @random_var * (pi / 2 - 2 * angle_var)
      pi * @quadrant + random_angle

    compute_random_radius: ->
      min_radius = @hole_radius + @inner_ring
      max_distance = @ring - @inner_ring - 2 * @hole_radius
      min_radius + @random_var * max_distance

    generate_obstacle: ->

      @amplitude = 50
      @period = 2000
      @anim = new Kinetic.Animation
        func: (frame) =>
          @obstacle.setX @amplitude * Math.sin(frame.time * 2 * Math.PI / @period) + @hole.getX()
          @obstacle.setY @amplitude * Math.cos(frame.time * 2 * Math.PI / @period) + @hole.getY()
        node: @layer
      @anim.start()