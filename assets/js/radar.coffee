define [
  'jquery'
  ,'underscore'
  , 'kinetic'
  , 'canvg'
  , 'technology_generator'
  , 'game_timer'
  , 'marble'
  , 'hole']
  , ($, _, Kinetic, canvg, TechnologyGenerator, GameTimer, Marble, Hole) ->

    class Round
      constructor: (options) ->
        @cast = options.cast || []
      
      play:(score)->
        roundOver = new $.Deferred
        # wake up all the actors - 
        @cast.map (c)-> 
          c.play().done ->
            roundOver.resolve(score+1)
        # put all the actors back to sleep (propogate sleep)
        roundOver.promise().pipe (score) => 
          @.complete().pipe -> 
            score

      complete: ->
        $.when.apply $, @cast.map (c)-> c.complete()

    class Radar
      constructor: (options)->
        @generator = new TechnologyGenerator(options.data)

        @stage = new Kinetic.Stage
              container: options.containerId
              width: options.width
              height: options.height

        @techLayer = new Kinetic.Layer
        @stage.add @techLayer

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

        @radar_centre = 
          x: @x-12
          y: @y

      decorateWithRealRadarPositions: ->
        @generator.randomSequence().map (tech)=>
          theta = -Math.PI * tech.pc.t/180.0
          new Kinetic.Circle
            x: @radar_centre.x + (0.75 * tech.pc.r * Math.cos(theta))
            y: @radar_centre.y + (0.75 * tech.pc.r * Math.sin(theta))
            radius: 5
            fill: "00b7db"
        .map (circle) =>
          @techLayer.add circle

        @techLayer.draw()

      play: ->
        endGamePromise = $.Deferred()
        @game_timer.startTimer().then ->
          console.log("Game Over!")
          endGamePromise.resolve()
        
        # @decorateWithRealRadarPositions()

        chainPromises = (memo,fn) -> 
          memo.pipe(fn)

        allRoundsPromise = _.chain(@generator.randomSequence())
        .map (tech) =>
          new Round
            cast: @create_cast_for_round(tech)
        .map (round) -> 
          round.play.bind(round)
        .reduce(chainPromises, $.when(0))
        .value()

        endGamePromise

      create_cast_for_round: (technology) ->
        hole = new Hole
          layer: @foregroundLayer
          quadrant: @quadrants[technology.quadrant].quadrant
          ring: @rings[technology.ring]
          center_x: @radar_centre.x
          center_y: @radar_centre.y
          hole_radius: 15

        marble = new Marble
          layer: @boardLayer
          label: technology.label
          board: @board
          hole : hole

        [marble, hole]

