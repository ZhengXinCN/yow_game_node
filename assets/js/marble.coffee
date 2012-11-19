define ['q', 'kinetic', 'underscore', 'audio', 'sylvester'], (Q, Kinetic, _, audio)->


  class Marble
    kCircleRadius = 15
    kAccelerationSensitivity = 2.0

    toVector: (xy)->
      $V([xy.x ? xy.getX?(), xy.y ? xy.getY?()])
    toXY: (v) ->
      x: v.e 1
      y: v.e 2
    setPosition: (shape, vec) ->
      shape.setPosition( (vec.e 1), (vec.e 2))

    constructor: (opts)->
      @text = opts.label
      @layer = opts.layer
      @debugLayer = opts.debugLayer
      @board = opts.board

      @piece =
        accel: $V([0,0])
        center: @toVector
          x: if Math.random() < 0.5 then 50 else @board.width-50
          y: @board.height/2
        delta: $V([0,0])
      @marble_radius = 15
      @shape = new Kinetic.Group @toXY(@piece.center)
      @shape.add new Kinetic.Circle
        radius: @marble_radius
        fill: "green"
      @shape.add new Kinetic.Circle
        radius: @marble_radius
        stroke: "#00FF00"
        strokeWidth: 2

      @hole = opts.hole.hole
      @obstacle = opts.hole.obstacle

      @label = new Kinetic.Text
        x: @piece.center.e 1
        y: @piece.center.e 2
        fontSize: 13
        fontFamily: "Helvetica"
        fontStroke: "black"
        textFill: "black"
        textStrokeWidth: 1
        text: @text

      @score = new Kinetic.Text
        x: @piece.center.e 1
        y: @piece.center.e 2
        fontSize: 20
        fontFamily: "Helvetica"
        fontStroke: "orange"
        textFill: "yellow"
        textStrokeWidth: 1
        text: "SCORE: +1"

    play: ->
      hitHole = Q.defer()
      @layer.add @shape
      @layer.add @label

      stopAnimation = ->
        mainAnimation.stop()
      
      marble_in_play = (frame)=>
        @piece = @computeCenter(@piece, frame)
        nextAnimation = marble_in_play
        if @detect_hole_collision()
          @scoring_feedback()
          hitHole.resolve this
          nextAnimation = stopAnimation

        @handle_obstacle_collision(frame)

        @piece = @limitBounds(@piece)

        @drawPiece()
        nextAnimation

      animFn = marble_in_play
      mainAnimation = new Kinetic.Animation
        func: (frame)=>
          animFn = animFn(frame)
        node: @layer
      mainAnimation.start()

      @detect_motion()
      @keyboard_motion()
      hitHole.promise

    complete: ->
      window.removeEventListener "devicemotion", @handler if @handler
      window.removeEventListener "keydown", @keyDownHandler if @keyDownHandler
      window.removeEventListener "keyup", @keyUpHandler if @keyUpHandler
      @handler = null
      @shape.remove()
      @label.remove()
      @layer.draw()
      this

    detect_motion: ->
      offset = $V([0,0])
      @handler = (event) =>
        accelPhysical =  event.accelerationIncludingGravity
        accel = $V([accelPhysical.y, accelPhysical.x])
        @piece.accel = accel.x(kAccelerationSensitivity).add(offset)

      window.addEventListener "devicemotion", @handler

    keyboard_motion: ->
      @keyDownHandler = (event) =>
        accel = (
          switch event.keyCode 
            when 37 then $V([-3, 0])
            when 38 then $V([0, -3])
            when 39 then $V([3, 0])
            when 40 then $V([0, 3])
          )
        @piece.accel = accel.x(kAccelerationSensitivity)
      window.addEventListener "keydown", @keyDownHandler

      @keyUpHandler = (event) =>
        if event.keyCode in [37,38,39,40] 
          accel = $V([0,0])
          @piece.accel = accel.x(kAccelerationSensitivity)
      window.addEventListener "keyup", @keyUpHandler

    scoring_feedback: -> 
      mid_point = @piece.center.subtract($V([0,15+10]))

      newMidPoint = mid_point.subtract($V([@score.getTextWidth(), @score.getTextHeight()]).x(0.5))
      @setPosition( @score, newMidPoint )

      fontSize = @score.getFontSize()
      @layer.add @score

      stopAnimation = -> 
        animation.stop()

      expandScore = (frame)=> 
        fontSize += (frame.timeDiff/200)
        @score.setFontSize fontSize
        newMidPoint = mid_point.subtract($V([@score.getTextWidth(), @score.getTextHeight()]).x(0.5))
        @setPosition( @score,  newMidPoint )

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
      # audio.ping.play()


    handle_obstacle_collision: (frame)->
      #algorithm from http://www.gamasutra.com/view/feature/131424/pool_hall_lessons_fast_accurate_.php
      u = frame.timeDiff / 1000
      delta = @piece.delta.x(u)
      centerA = @piece.center
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

      movedCenterA = centerA.add(moveToEdge)
      centerLine = centerB.subtract movedCenterA

      nCenter = centerLine.toUnitVector()

      v1 = moveVec
      v2 = @obstacle.delta.x(u)
      a1 = v1.dot nCenter
      a2 = v2.dot nCenter
      optimisedP = (2.0*(a1-a2))/(1 + 100)
      v1_ = v1.subtract( nCenter.x(optimisedP).x(100))
      # v2_ = v2.add( nCenter.x(optimisedP).x(1))

      newCenterA = movedCenterA.add v1_.toUnitVector().x( sumRadii )
      @piece.delta = v1_.x(2/u)
      @piece.center = newCenterA

      true

    detect_hole_collision: ->
      actualDistance = @piece.center.distanceFrom @toVector(@hole)
      sumOfRadii = 15 + @hole.getRadius()
      actualDistance < sumOfRadii

    computeCenter: (oldPiece, frame) ->
      u = frame.timeDiff / 1000
      friction = Math.min(1.0,u)
      delta = oldPiece.accel.add(oldPiece.delta).x(1-friction)
      newPiece = 
        accel: oldPiece.accel
        delta: delta
        center: oldPiece.center.add(delta.x(u))

    limitBounds: (piece)->
      bound = (x,min,max) -> 
        if min < x < max
          [false,x]
        else
          [true, Math.max(min, Math.min(max, x))]

      # do not go outside the boundaries of the canvas
      [boundedX, newX] = bound((piece.center.e 1), kCircleRadius, @board.width - kCircleRadius)
      [boundedY, newY] = bound((piece.center.e 2), kCircleRadius, @board.height - kCircleRadius)

      piece.center = $V([newX,newY])
      piece.delta = $V([
        if boundedX then 0 else piece.delta.e 1,
        if boundedY then 0 else piece.delta.e 2
      ])

      piece

    drawPiece: ->
      @setPosition(@shape, @piece.center)
      textOffset = $V([(@label.getTextWidth() / -2), (-kCircleRadius - @label.getTextHeight() - 5)])
      @setPosition(@label, @piece.center.add(textOffset))
