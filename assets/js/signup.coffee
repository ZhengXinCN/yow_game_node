class @Signup
  capture: ->
    promise = new $.Deferred
    $('#form form').submit ->
      promise.resolve()
      false
    promise