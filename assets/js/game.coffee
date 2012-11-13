define [
  'jquery'
  ,'q'
  ,'radar'
  ,'signup']
  , ($, Q, Radar, Signup) -> 
    game = -> 
      game_countdown = 25;
      replay_countdown = 5;


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
        defer = Q.defer()
        $('#play').click -> 
          defer.resolve(data);
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
        tick = (delay)->
          Q.delay(delay-1, 1000)
          .then (remaining)->
            $( options.countdownSelector || '.countdown').text(remaining + ' ')
            tick(remaining)

        duration = options.replay_countdown || 15
        tick(duration)
        
        restart = Q.defer()
        restartDone = restart.resolve.bind restart, true
        
        $(options.restartSelector).click restartDone
        Q.delay(duration*1000).then restartDone
        restart.promise 

      update_score = (score) ->
        $("#score").text(score)

      abort_game = (message)->
        window.location.reload()


      trace = (message) =>
        debug_message = (message, err)->
          err
        debug_message.bind(this, message)

      Q.when($.getJSON('/data'))
      .then( normalise_for_radar,trace(1) )
      .then( transition('#intro #play'), trace(2))
      .then( intro_phase, trace(3) )
      .then( transition('#intro,#game'), trace(4))
      .then( play_phase, trace(5))
      .then( transition('#game,#result'), abort_game.bind(this), update_score)
      .then( replay_phase.bind(this,
        duration: replay_countdown
        countdownSelector:'#result .countdown'
        restartSelector: '#result #restart'
      )).then( abort_game.bind(this) )