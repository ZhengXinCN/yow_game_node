define [
  'jquery'
  ,'q.interval'
  ,'underscore'
  ,'statemachine'
  ,'radar'
  ,'games'
  ,'signup']
  , ($, Q, _, StateMachine, Radar, games, Signup) ->
    game = ->
      game_countdown = 30;
      replay_countdown = 45;

      fsm = StateMachine.create
        initial: 'starting'
        events: [
          { name: 'dataLoaded', from: 'starting', to: 'introduction' }
          { name: 'requestPlay', from: 'introduction', to: 'playing'    },
          { name: 'gameOver',  from: 'playing',    to: 'played' },
          { name: 'timeout', from: 'played', to: 'ended'}
        ]
        callbacks:
          onenterintroduction: ->
            $('#play').attr('disabled', null)
            $("#intro").removeClass('hidden')
            true
          onleaveintroduction: ->
            $("#intro").addClass('hidden')
            true

          onenterplaying: ->
            $("#game").removeClass('hidden')
            true
          onleaveplaying: ->
            $("#game").addClass('hidden')
            true

          onenterplayed: ->
            $("#result").removeClass('hidden')
            replay_phase
              duration: replay_countdown
              countdownSelector:'#result #restart'
              restartSelector: '#result button'
            .then ->
              fsm.timeout()
            true

          onleaveplayed: ->
            $("#result").addClass('hidden')
            true

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
              fsm.gameOver(game_state)
            true

          ongameOver: (evt, from, to, game_state) ->
            game = record_game(game_state)
            game = sync_scores(game)
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

      signup_phase = ->
        new Signup({containerId: 'form'}).capture()

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
