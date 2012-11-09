class @Radar

  constructor: (options)->
    @generator = new TechnologyGenerator(options.data)

    @stage = new Kinetic.Stage
          container: options.containerId
          width: options.width
          height: options.height


    @timerLayer = new Kinetic.Layer
    @stage.add @timerLayer

    @backgroundLayer = new Kinetic.Layer
    @stage.add @backgroundLayer
        
    @boardLayer = new Kinetic.Layer
    @stage.add @boardLayer


    @x = @stage.getWidth() / 2
    @y = @stage.getHeight() / 2

    @foregroundLayer = new Kinetic.Layer
    @stage.add @foregroundLayer


    @board = 
      layer: @boardLayer
      width: options.width
      height: options.height

    @game_timer = new GameTimer
      layer: @timerLayer
      board: @board
      remainingSeconds: options.duration || 10

    $(@backgroundLayer.getCanvas().element).attr('id', 'backgroundLayer');
    canvg('backgroundLayer', options.background_svg, { ignoreMouse: true, ignoreAnimation: true });

    @rings =
      "Adopt":
        inner:15
        outer:90
      "Trial":
        inner:90
        outer:160
      "Assess":
        inner:160
        outer:230
      "Hold":
        inner:230
        outer:300
    @quadrants =
      "Languages & Frameworks":
        quadrant: 0.0
      "Tools":
        quadrant: 0.5
      "Techniques":
        quadrant: 1.0
      "Platforms":
        quadrant: 1.5

  play: ->
    endGamePromise = $.Deferred()
    @game_timer.startTimer().then ->
      console.log("Game Over!")
      endGamePromise.resolve()
    technology = @generator.get_random_technology()
    @draw_hole(technology)
    @draw_marble(technology)
    endGamePromise

  draw_marble: (technology) ->
    @marble = new Marble
      layer: @boardLayer
      label: technology.label
      board: @board
      hole : @hole.hole


    @marble.detect_motion()

  draw_hole: (technology) ->
    @hole = new Hole
      layer: @foregroundLayer
      quadrant: @quadrants[technology.quadrant].quadrant
      ring: @rings[technology.ring]
      center_x: @x-12
      center_y: @y
      hole_radius: 15

    @hole.draw_hole()


