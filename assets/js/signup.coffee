define ['jquery', 'q', 'jquery.form'], ($, Q)->
  $.fn.ajaxSubmit.debug = true
  class @Signup
    constructor: (options) ->
      @data = options.data || {}

    capture: ->
      promise = Q.defer()
      $('form#signup').ajaxForm
        dataType: 'json'
        type: 'POST'
        data: @data
        headers:
          Accept: 'application/json'
        success: (res) ->
          promise.resolve res
        error: ->
          promise.reject()
      promise.promise
  Signup