define [], ->
  localStorage = window.localStorage
  model = ->
    JSON.parse(localStorage.getItem("games")) || []

  update_model = (fn)->
    new_collection = fn.call(this, model())
    localStorage.setItem("games", JSON.stringify(new_collection))

  with_model = (fn)->
    old_collection = _.clone(model())
    fn.call(this,old_collection)

  definition =
    addGame: (item)->
      update_model (collection)->
        collection.splice(0,0, item)
        collection

    topScores: ->
      with_model (games)->
        _.chain(games)
        .pluck("score")
        .filter (s)->
          s>0
        .sortBy (s)->
          -s
        .value()

    latestScores: ->
      with_model (games)->
        _.chain(games)
        .sortBy (s) ->
          -(s.timestamp)
        .pluck("score")
        .value()
