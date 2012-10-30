class @GameTimer
  start_timer: (starting_value)->
    console.log "Starting value #{starting_value}"
    if starting_value == 0
      console.log "redirect"
    else
      @timer = window.setTimeout =>
        @start_timer(starting_value-1)
      ,1000
