define ['jquery', 'q', 'jquery.form'], ($, Q)->
  $.fn.ajaxSubmit.debug = true
  class @Signup
    constructor: (options) ->
      @model = options.model || {}

    capture: ->
      promise = Q.defer()
      $('form#signup').ajaxForm
        dataType: 'json'
        type: 'POST'
        data: @model
        headers:
          Accept: 'application/json'
        success: (res) ->
          promise.resolve res
        error: ->
          promise.reject()
      promise.promise
  Signup