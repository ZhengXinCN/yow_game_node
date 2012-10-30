class @IdleTimer
  constructor:(amount_of_secs) ->
    @amount_of_secs = amount_of_secs

  start_timer: ->
      @timer = window.setInterval ->
        console.log "timer fired"
      ,10000

  restart_timer: ->
      window.clearInterval @timer
      @start_timer()



