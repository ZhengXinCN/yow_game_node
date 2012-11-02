class @Radar

  constructor: (options)->
    @generator = new TechnologyGenerator(options.data)

    @stage = new Kinetic.Stage
          container: 'container'
          width: options.width
          height: options.height


    @timerLayer = new Kinetic.Layer
    @stage.add @timerLayer

    @backgroundLayer = new Kinetic.Layer
    @stage.add @backgroundLayer
        
    @boardLayer = new Kinetic.Layer
    @stage.add @boardLayer

    @foregroundLayer = new Kinetic.Layer
    @stage.add @foregroundLayer

    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @board = 
      layer: @boardLayer
      width: options.width
      height: options.height

    @game_timer = new GameTimer
      layer: @timerLayer
      board: @board
      remainingSeconds: 10

    $(@backgroundLayer.getCanvas().element).attr('id', 'backgroundLayer');
    canvg('backgroundLayer', options.background_svg, { ignoreMouse: true, ignoreAnimation: true });


  play: ->
    @game_timer.startTimer()
    @draw_marble(@generator.get_random_technology())

  draw_marble: (technology) ->

    @marble = new Marble
      layer: @boardLayer
      label: technology.label
      board: @board

    @marble.detect_motion(@boardLayer)

