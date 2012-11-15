define ['q', 'kinetic', 'underscore', 'sylvester'], (Q, Kinetic, _)->

  class Marble
    kCircleRadius = 15
    kAccelerationSensitivity = 1.5

    toVector: (xy)->
      $V([xy.x ? xy.getX?(), xy.y ? xy.getY?()])
    toXY: (v) ->
      x: v.e 1
      y: v.e 2

    constructor: (opts)->
      @text = opts.label
      @layer = opts.layer
      @debugLayer = opts.debugLayer
      @board = opts.board
      @piece =
        center:
          x: @board.width / 2
          y: @board.height / 2
          delta:
            x:0
            y:0
        color: '#298EC3'
      @marble_radius = 15
      @shape = new Kinetic.Group
        x: @piece.center.x
        y: @piece.center.y
      @shape.add new Kinetic.Circle
        radius: @marble_radius
        fill: "red"
      @shape.add new Kinetic.Circle
        radius: @marble_radius
        stroke: "white"
        strokeWidth: 2

      @hole = opts.hole.hole
      @obstacle = opts.hole.obstacle

      @label = new Kinetic.Text
        x: @piece.center.x
        y: @piece.center.y
        fontSize: 13
        fontFamily: "Helvetica"
        fontStroke: "black"
        textFill: "black"
        textStrokeWidth: 1
        text: @text

      @score = new Kinetic.Text
        x: @piece.center.x
        y: @piece.center.y
        fontSize: 20
        fontFamily: "Helvetica"
        fontStroke: "silver"
        textFile: "silver"
        textStrokeWidth: 1
        text: "SCORE: +1"
      @state = "off"

    play: ->
      @layer.add @shape
      @layer.add @label
      @mainAnimation = new Kinetic.Animation
        func: (frame)=>
          @update(frame)
        node: @layer
      .start()
      @detect_motion()

    update: (frame)->
      @drawPiece()

    complete: ->
      window.removeEventListener "devicemotion", @handler if @handler
      @handler = null
      @shape.remove()
      @label.remove()
      this

    detect_motion: ->
      hitHole = Q.defer()

      @handler = (event) =>
        accel = event.accelerationIncludingGravity

        @piece.center = @computeCenter(@piece.center, accel)
        @piece.color = '#298EC3'
        if @detect_hole_collision()
          @scoring_feedback()
          hitHole.resolve this

        if @handle_obstacle_collision()
          @obstacle.setFill "green"
        else
          @obstacle.setFill "yellow"

      window.addEventListener "devicemotion", @handler
      hitHole.promise

    scoring_feedback: -> 
      mid_point = 
        x: @piece.center.x
        y: @piece.center.y - 15 - 10
      @score.setX mid_point.x
      @score.setY mid_point.y

      

      fontSize = @score.getFontSize()
      @layer.add @score

      stopAnimation = -> 
        animation.stop()

      expandScore = (frame)=> 
        fontSize += (frame.timeDiff/200)
        @score.setFontSize fontSize
        @score.setX mid_point.x - (@score.getTextWidth() / 2)
        @score.setY mid_point.y - (@score.getTextHeight() / 2)
        console.log @score.getTextStroke()

        if( fontSize > 25)
          @score.remove()
          stopAnimation
        else
          expandScore

      nextFunc = expandScore
      animation = new Kinetic.Animation
        func: (frame) =>
          nextFunc = nextFunc(frame)
        node: @layer
      
      animation.start()


    handle_obstacle_collision: ->
      #algorithm from http://www.gamasutra.com/view/feature/131424/pool_hall_lessons_fast_accurate_.php
      delta = @toVector @piece.center.delta
      centerA = @toVector @piece.center
      centerB = @toVector @obstacle

      moveVec = delta
      centerDistance = centerA.distanceFrom(centerB)
      sumRadii = @obstacle.getRadius() + 15
      centerDistance -= sumRadii
      modMove = moveVec.modulus()

      return false if modMove < centerDistance

      n = moveVec.toUnitVector()
      centerLine = centerB.subtract centerA
      dot = n.dot centerLine
      return false if dot <= 0 #A is moving away from B

      centerLineLength = centerLine.modulus()
      f = (centerLineLength * centerLineLength) - (dot * dot)
      sumRadiiSquared = sumRadii * sumRadii
      #No colliion if their centers won't overlap
      return false if f > sumRadiiSquared

      t = sumRadiiSquared - f
      return false if t < 0

      distanceToMove = dot-Math.sqrt(t)

      # return false if distanceToMove < modMove

      # Now calculate new deltas for collision
      moveToEdge = moveVec.toUnitVector().x(distanceToMove)

      movedCenterA = @toVector(@piece.center).add(moveToEdge)
      centerLine = centerB.subtract movedCenterA

      nCenter = centerLine.toUnitVector()

      v1 = moveVec
      v2 = @toVector @obstacle.delta
      a1 = v1.dot nCenter
      a2 = v2.dot nCenter
      optimisedP = (2.0*(a1-a2))/(1 + 100)
      v1_ = v1.subtract( nCenter.x(optimisedP).x(100))
      # v2_ = v2.add( nCenter.x(optimisedP).x(1))

      @piece.center.delta = @toXY v1_.x(5)
      newCenterA = movedCenterA.add v1_.x(5)
      @piece.center.x = newCenterA.e 1
      @piece.center.y = newCenterA.e 2

      true

    detect_hole_collision: ->
      actualDistance = @toVector(@piece.center).distanceFrom @toVector(@hole)
      sumOfRadii = 15 + @hole.getRadius()
      actualDistance < sumOfRadii

    computeCenter: (oldCenter, acceleration, direction) ->
      accel =
        x:0.8 + (acceleration.y * kAccelerationSensitivity)
        y:0.8 + (acceleration.x * kAccelerationSensitivity)
      delta =
        x:(accel.x + oldCenter.delta.x) / 1.5
        y:(accel.y + oldCenter.delta.y) / 1.5
      newCenter = 
        delta: delta
        x: oldCenter.x + delta.x
        y: oldCenter.y + delta.y

      bound = (x,min,max) -> 
        if min < x < max
          [false,x]
        else
          [true, Math.max(min, Math.min(max, x))]

      # do not go outside the boundaries of the canvas
      [bounded, newCenter.x] = bound(newCenter.x, kCircleRadius, @board.width - kCircleRadius)
      newCenter.delta.x = 0 if bounded

      [bounded, newCenter.y] = bound(newCenter.y, kCircleRadius, @board.height - kCircleRadius)
      newCenter.delta.y = 0 if bounded

      newCenter

    drawPiece: ->
      @shape.setPosition(@piece.center.x, @piece.center.y)
      @label.setPosition(@piece.center.x - @label.getTextWidth() / 2, @piece.center.y - kCircleRadius - @label.getTextHeight() - 5);
