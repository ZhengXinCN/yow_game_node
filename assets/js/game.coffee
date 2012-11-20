define [
  'jquery'
  ,'q.interval'
  ,'underscore'
  ,'radar'
  ,'games'
  ,'signup']
  , ($, Q, _, Radar, games, Signup) ->
    game = ->
      game_countdown = 30;
      replay_countdown = 45;


      normalise_for_radar = (data) ->
        data.technologies = data.radar_data.map (input) ->
          tech =
            label: input.name
            pc: input.pc
            quadrant: if input.pc.t < 90
              "Tools"
            else if input.pc.t < 180
              "Techniques"
            else if input.pc.t < 270
              "Platforms"
            else
              "Languages & Frameworks"
            ring: if input.pc.r < 150
              "Adopt"
            else if input.pc.r < 270
              "Trial"
            else if input.pc.r < 340
              "Assess"
            else
              "Hold"
        data

      intro_phase = (data) ->
        $('#play').attr('disabled', null)
        defer = Q.defer()
        $('#play').click ->
          $('#play').attr('disabled', 'disabled')
          setTimeout ->
            defer.resolve(data)
          , 100
        defer.promise

      play_phase = (data)->
        radar = new Radar
          width: 864
          height: 694
          data: data
          containerId: 'radar'
          background_svg : 'radar.svg'
          duration: game_countdown
        radar.play()

      transition = (selectors) -> (data) ->
        $(selectors).toggleClass('hidden')
        return data;

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

      trace = (message) =>
        (err) -> err

      Q.when($.getJSON('/data'))
      .then( normalise_for_radar,trace(1) )
      .then( transition('#intro #play'), trace(2))
      .then( intro_phase, trace(3) )
      .then( transition('#intro,#game'), trace(4))
      .then( play_phase, trace(5))
      .then( record_game )
      .then( sync_scores )
      .then( transition('#game,#result'), (=> abort_game(arguments...)))
      # .then( transition( '#intro,#result'))
      .then( => replay_phase
        duration: replay_countdown
        countdownSelector:'#result #restart'
        restartSelector: '#result button'
      ).then( => abort_game(arguments...) )