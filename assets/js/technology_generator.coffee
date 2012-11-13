define ['underscore'],(_) ->
  class TechnologyGenerator
    constructor: (json)->
      @technologies = json.technologies

    get_random_technology: ->
      random_index = Math.floor(Math.random() * @technologies.length)
      @technologies[random_index]

    randomSequence: ->
      _.shuffle(@technologies)

  TechnologyGenerator