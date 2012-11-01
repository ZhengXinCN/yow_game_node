class @Radar

  constructor: (options)->
    console.log(options)
    @stage = new Kinetic.Stage
          container: 'container'
          width: options.width
          height: options.height

    @foregroundLayer = new Kinetic.Layer()
    $(@foregroundLayer.canvas.element).addClass("foreground")
    @stage.add @foregroundLayer

    @backgroundLayer = new Kinetic.Layer()
    @stage.add @backgroundLayer
        
    @boardLayer = new Kinetic.Layer()
    @stage.add @boardLayer

    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @board = 
      layer: @boardLayer
      width: options.width
      height: options.height

  draw_marble: (technology) ->
    @marble = new Marble
      layer: @boardLayer
      label: technology.label
      board: @board

    @marble.detect_motion(@boardLayer)

