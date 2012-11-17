define ['jquery', 'q', 'buzz'], ($,Q, buzz)->

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


  ping = new buzz.sound '/ping.mp3',
    formats: ["mp3"]
    preload: true
  ping.load()
  ping

  ping: ping

  
