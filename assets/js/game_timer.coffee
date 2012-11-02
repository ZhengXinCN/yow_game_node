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

  startTimer: ->
    @tick()

  tick:->
    if @remainingSeconds == 0
      @layer.remove @text
      @draw
    else
      @draw()
      @timer = window.setTimeout =>
        @remainingSeconds = @remainingSeconds-1
        @tick()
      ,1000

  draw: ->
    @text.setText(@remainingSeconds)
    @text.setPosition (@board.width - @text.getTextWidth()) / 2, (@board.height - @text.getTextHeight()) / 2
    @layer.draw()


