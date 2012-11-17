define ['q'], (Q)->
  Q.interval = (tick, duration, resolution = true) ->
    d = Q.defer()
    timerState = 
      active: true
      elapsed: 0
      remaining: duration
      duration: duration
      promise: d.promise

    intervalId = window.setInterval ->
      timerState.elapsed += tick
      timerState.remaining -= tick
      timerState.progress = timerState.elapsed/timerState.duration
      d.notify timerState
      if timerState.remaining <= 0
        window.clearInterval intervalId
        d.resolve resolution
    ,tick

    d.promise
  Q
