class TechnologyGenerator
  constructor: (json)->
    @technologies = json.technologies

  get_random_technology: ->
    random_index = Math.floor(Math.random() * @technologies.length)
    @technologies[random_index]

if module? and module.exports?
  module.exports.TechnologyGenerator = TechnologyGenerator
else window.TechnologyGenerator = TechnologyGenerator