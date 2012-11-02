class @GameTimer

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
    @remainingSeconds = options.remainingSeconds

    @timer_bar = new Kinetic.Rect
      x: @board.width - 70
      y: @board.height - 600
      width:50
      height: 400
      fill: "lightBlue"
      stroke: "lightBlue"
      strokeWidth: 2

    @layer.add @timer_bar
    @timer_bar_decrement_unit = @timer_bar.getHeight() / options.remainingSeconds

  startTimer: ->
    endGamePromise = $.Deferred()
    tick = =>
      if @remainingSeconds == 0
        @layer.remove @text
        @draw()
        endGamePromise.resolve()
      else
        @draw()
        @timer = window.setTimeout =>
          @remainingSeconds = @remainingSeconds-1
          @timer_bar.setHeight(@timer_bar.getHeight() - @timer_bar_decrement_unit)
          tick()
        ,1000
    tick()
    endGamePromise

  draw: ->
    if @remainingSeconds <= 5
      @text.setText(@remainingSeconds)
      @text.setPosition (@board.width - @text.getTextWidth()) / 2, (@board.height - @text.getTextHeight()) / 2
    @layer.draw()


