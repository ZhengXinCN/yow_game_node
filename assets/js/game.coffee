define [
  'jquery.timeout'
  ,'radar'
  ,'signup']
  , ($, Radar, Signup) -> 
  
    

    game = -> 
      game_countdown = 10;
      replay_countdown = 5;


      intro_phase = (data) ->
        defer = new $.Deferred
        $('#play').click -> 
          defer.resolve(data);
        defer

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
          $.timeout(1000, delay-1)
          .pipe (remaining)->
            $( options.countdownSelector || '.countdown').text(remaining + ' ')
            tick(remaining)

        duration = options.replay_countdown || 15
        tick(duration)
        
        restart = new $.Deferred
        restartDone = restart.resolve.bind restart
        
        $(options.restartSelector).click restartDone
        $.timeout(duration*1000).then restartDone
        restart 


      $.getJSON('/data')
      .pipe( intro_phase )
      .pipe( transition('#intro,#game') )
      .pipe( play_phase )
      .pipe( transition('#game,#result'))
      .pipe( replay_phase.bind(this,
        duration: replay_countdown
        countdownSelector:'#result .countdown'
        restartSelector: '#result #restart'
      )).pipe -> location.reload()