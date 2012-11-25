define [
  'jquery'
  ,'q.interval'
  ,'underscore'
  ,'statemachine'
  ,'radar'
  ,'games'
  ,'signup']
  , ($, Q, _, StateMachine, Radar, games, Signup) ->

    class Model
      game: null
      punter: null

    game = ->
      game_countdown = 30
      replay_countdown = 45
      winning_score = 3

      model = new Model()

      fsm = StateMachine.create
        initial: 'starting'
        events: [
          { name: 'dataLoaded',    from: 'starting',                  to: 'introduction'   },
          { name: 'requestPlay',   from: 'introduction',              to: 'playing'        },
          { name: 'gameOverWin',   from: 'playing',                   to: 'playedAndWon'   },
          { name: 'signedUp',      from: 'playedAndWon',              to: 'played'         },
          { name: 'gameOverLoss',  from: 'playing',                   to: 'playedAndLost'  },
          { name: 'timeout',       from: ['playedAndLost', 'played'], to: 'ended'          }
        ]
        error: (eventName, from, to, args, errorCode, errorMessage) ->
          console.log('event ' + eventName + ' was naughty :- ' + errorMessage)
        callbacks:
          onenterstarting: ->
            state.game = null
            true

          onenterintroduction: ->
            $('#play').attr('disabled', null)
            $("#intro").addClass('active')
            true
          onleaveintroduction: ->
            $("#intro").removeClass('active')
            true

          onenterplaying: ->
            $("#game").addClass('active')
            true
          onleaveplaying: ->
            $("#game").removeClass('active')
            true

          onenterplayedAndLost: ->
            $("#result, #result .loser").addClass('active')
            replay_phase
              duration: replay_countdown
              countdownSelector:'#result #restart'
              restartSelector: '#result button'
            .then ->
              fsm.timeout()
            true
          onleaveplayedAndLost: ->
            $("#result, #result .loser").removeClass('active')
            true

          onenterplayedAndWon: ->
            $("#result, #result .winner").addClass('active')
            new Signup({containerId: 'form', data: { game: [model.game]}}).capture().then (punter)->
              model.punter = punter
            .then (punter)->
              fsm.signedUp(punter)

          onleaveplayedAndWon: ->
            $("#result, #result .winner").removeClass('active')

          onenterplayed: ->
            $("#result, #result .played").addClass('active')
            replay_phase
              duration: replay_countdown
              countdownSelector:'#result #restart'
              restartSelector: '#result button'
            .then ->
              fsm.timeout()

          onleaveplayed: ->
            $("#result, #result .played").removeClass('active')

          onenterended: ->
            window.location.reload()

          ondataLoaded: (evt, from, to, data) ->
            data = normalise_for_radar(data)

            $('#play').removeClass('hidden').click ->
              $('#play').attr('disabled', 'disabled')
              setTimeout((-> fsm.requestPlay(data)), 100)
            true

          onrequestPlay: (evt, from, to, data) ->
            radar = new Radar
              width: 864
              height: 694
              data: data
              containerId: 'radar'
              background_svg : 'radar.svg'
              duration: game_countdown
            radar.play().then (game_state)->
              game_state = record_game(game_state)
              game_state = sync_scores(game_state)
              model.game = game_state
              if game_state.score >= winning_score
                fsm.gameOverWin()
              else
                fsm.gameOverLoss()
            true

      Q.when($.getJSON('/data'))
      .then (data)->
        fsm.dataLoaded(data)

      normalise_for_radar = (data) ->
        data.technologies = data.radar_data.map (input) ->
          tech =
            label: input.name
            pc: input.pc
        data

      replay_phase = (options) ->
        restart = Q.defer()
        restartDone = -> restart.resolve true

        duration = options.duration || 15

        updateCountdown = (seconds) ->
          $(options.countdownSelector || '.countdown').text( seconds + ' ')

        Q.interval(1000, duration * 1000).progress (timer) ->
          updateCountdown Math.ceil(timer.remaining/1000)
        .then restartDone
        $(options.restartSelector).click restartDone

        updateCountdown duration
        restart.promise

      sync_scores = (game) ->
        $("#score").text(game.score)
        topScores = _.take(games.topScores(), 3).join(' ')
        latestScores = _.take(games.latestScores(), 3).join(' ')

        $("#top_scores").text(topScores)
        $("#latest_scores").text(latestScores)
        game

      record_game = (game) ->
        game.timestamp = Date.now()
        games.addGame(game)
        game

      abort_game = (message)->
        window.localStorage.setItem("lasterror", JSON.stringify(message))
        window.location.reload()
