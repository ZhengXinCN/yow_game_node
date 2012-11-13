stripExt = (filePath) ->
  if (lastDotIndex = filePath.lastIndexOf '.') >= 0
    filePath[0...lastDotIndex]
  else
    filePath

server = (options)->
  express = require 'express'
  stylus = require 'stylus'
  assets = require 'connect-assets'
  resource = require 'express-resource'
  file = require "file"
  _ = require "underscore"
  # {db} = options

  app = express()
  
  # Add Connect Assets
  app.use assets()

  asset_js_path = "#{process.cwd()}/assets/js/"

  file.walkSync asset_js_path, (dirPath,dirs,files) ->
    files?.map _.compose(assets.instance.options.helperContext.js,stripExt)
    true

   # Set the public folder as static assets
  app.use express.static(process.cwd() + '/public')

  app.use express.bodyParser()

  # Set View Engine
  app.set 'view engine', 'jade'
  # Get root_path return index view
  app.get '/', (req, resp) ->
    resp.render 'index'

  app.get '/data', (req,resp) ->
    json = require '../data/techradar.json'
    resp.set
      'Content-Type': 'text/json'
    resp.send json

  app.resource('punters', require('./punter').resource(options))
  app

exports.server = server