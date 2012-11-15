define ['q.interval', 'kinetic'], (Q, Kinetic) ->
  class GameTimer

    constructor: (options) ->
      @layer = options.layer
      @board = options.board
      @text = new Kinetic.Text
        x: @board.width / 2
        y: @board.height / 2
        fontSize: 400
        fontFamily: "Helvetica"
        fontStroke: "grey"
        textFill: "grey"
        textStrokeWidth: 1
      @layer.add @text
      @duration = options.remainingSeconds * 1000

      @timer_bar = new Kinetic.Rect
        x: @board.width - 70
        y: @board.height - 600
        width:50
        height: 400
        fill: "lightBlue"
        stroke: "lightBlue"
        strokeWidth: 2

      @startingHeight = @timer_bar.getHeight()

    play: ->
      startTimer()

    startTimer: ->
      @layer.add @timer_bar
      @layer.draw()

      endGamePromise = Q.defer()

      Q.interval(100, @duration).progress (timer) =>
        @draw(Math.ceil(timer.remaining/1000), timer.progress)
      .then =>
        @text.remove()
        @timer_bar.remove()
        endGamePromise.resolve(true)

      endGamePromise.promise

    draw: (remainingSeconds, progress)->
      if remainingSeconds <= 5
        @text.setText(remainingSeconds)
        @text.setPosition (@board.width - @text.getTextWidth()) / 2, (@board.height - @text.getTextHeight()) / 2
      
      @timer_bar.setHeight(@startingHeight * (1-progress))
      @layer.draw()


