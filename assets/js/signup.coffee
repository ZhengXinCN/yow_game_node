class @Signup
  capture: ->
    promise = new $.Deferred    
    $('#form form').submit (event)->
      event.preventDefault()
      if !!@action
        $.ajax
          url: @action
          type: 'POST'
          data: 
            fullName: 'Manny'
            company: 'cat'
            emailAddress: 'nick@test'
          headers:
            Accept: 'application/json'
        .success (res) ->
          promise.resolve res
      else 
        promise.resolve()
    promise