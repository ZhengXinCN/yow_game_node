define [
  'jquery'
  ,'q'
  ,'underscore'
  , 'kinetic'
  , 'canvg'
  , 'technology_generator'
  , 'game_timer'
  , 'marble'
  , 'hole']
  , ($, Q, _, Kinetic, canvg, TechnologyGenerator, GameTimer, Marble, Hole) ->

    Q.union = (promises)->
      union = Q.defer()
      promises.map (arg) ->
        Q.when arg, (value)->
          union.resolve(value)
      union.promise

    class Round
      constructor: (options) ->
        @cast = options.cast || []

      play:(game_state)->
        # wake up all the actors -
        Q.union(@cast.map (c)-> c.play())
        .then (value)=>
          Q.all(@cast.map (c)-> c.complete())
        .then ->
          _.extend({}, game_state, {score: game_state.score+1})

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

        @xy = $V([@stage.getWidth(), @stage.getHeight()]).x(0.5)

        @foregroundLayer = new Kinetic.Layer
        @stage.add @foregroundLayer

        @debugLayer = new Kinetic.Layer
        @stage.add @debugLayer

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

        @radar_centre = @xy.add($V([-12,0]))

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
        state =
          score: 0

        endGamePromise = Q.defer()
        @game_timer.startTimer().then ->
          console.log("Game Over!")
          endGamePromise.resolve(state)

        # @decorateWithRealRadarPositions()

        chainPromises =(memo,fn) ->
          memo.then(fn).then (score) ->
            endGamePromise.notify score
            score

        allRoundsPromise = _.chain(@generator.randomSequence())
        .map (tech) =>
          new Round
            cast: @create_cast_for_round(tech)
        .map (round) ->
          round.play.bind(round)
        .reduce(chainPromises, Q.resolve(state))
        .value()

        endGamePromise.promise.progress (new_state)->
          state = new_state

      create_cast_for_round: (technology) ->
        # console.log JSON.stringify(technology)
        theta = -Math.PI * technology.pc.t/180.0

        offsetFromCenter = $V([Math.cos(theta), Math.sin(theta)]).x(0.75).x(technology.pc.r)
        holeCenter = offsetFromCenter.add(@radar_centre)
        hole = new Hole
          layer: @foregroundLayer
          x: holeCenter.e(1)
          y: holeCenter.e(2)
          hole_radius: 15

        marble = new Marble
          layer: @boardLayer
          debugLayer: @debugLayer
          label: technology.label
          board: @board
          hole : hole

        [marble, hole]

