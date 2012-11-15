define ['jquery', 'q'], ($,Q)->

  class Sound
    constructor: (context, buffer) ->
      @buffer = buffer
      @context = context

    play: ->
      source = @context.createBufferSource()
      source.buffer = @buffer;
      source.connect @context.destination
      source.noteOn 0
      this


  sounds = 
    ping: Q.defer()

  $ ->
    context = new webkitAudioContext() 
    request = new XMLHttpRequest()
    request.open('GET', '/ping.aif', true)
    request.responseType = 'arraybuffer'

    # Decode asynchronously
    request.onload = ->
      context.decodeAudioData request.response, (buffer)->
        sounds.ping.resolve new Sound(context, buffer)
      , (err)-> console.log err
    request.send()

  promises = 
    ping: sounds.ping.promise

  
