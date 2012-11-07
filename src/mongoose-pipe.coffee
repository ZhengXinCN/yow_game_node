{Promise} = require 'mongoose'

Promise::pipe = (success, failure) ->
  nextPromise = new Promise()
  identity = (i) -> i
  success = success || identity
  failure = failure || identity

  @addBack (error, value) -> 
    [trigger, processed] = if error
      [nextPromise.error, failure(error)]
    else
      [nextPromise.complete, success(value)]

    if processed instanceof Promise
      processed.addErrback nextPromise.error.bind(nextPromise)
      processed.addCallback nextPromise.complete.bind(nextPromise)
    else
      trigger.bind(nextPromise)(processed)
  
  nextPromise

Promise::resolver = () ->
	@resolve.bind(@)