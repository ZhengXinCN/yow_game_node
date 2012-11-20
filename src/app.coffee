
assetize_javascript_for_requirejs = (assets)->
  file = require "file"
  _ = require "underscore"

  stripExt = (filePath) ->
    if (lastDotIndex = filePath.lastIndexOf '.') >= 0
      filePath[0...lastDotIndex]
    else
      filePath

  asset_js_path = "#{process.cwd()}/assets/js/"
  asset_css_path = "#{process.cwd()}/assets/css/"

  file.walkSync asset_js_path, (dirPath,dirs,files) ->
    files?.map _.compose(assets.instance.options.helperContext.js,stripExt)
    true
  file.walkSync asset_css_path, (dirPath,dirs,files) ->
    files?.map _.compose(assets.instance.options.helperContext.css,stripExt)
    true

server = (options)->
  express = require 'express'
  stylus = require 'stylus'
  assets = require 'connect-assets'
  resource = require 'express-resource'
  timestamp = Date.now()

  # {db} = options

  app = express()

  # Add Connect Assets
  app.use assets()

  assetize_javascript_for_requirejs assets

   # Set the public folder as static assets
  app.use express.static(process.cwd() + '/public')

  app.use express.bodyParser()

  # Set View Engine
  app.set 'view engine', 'jade'
  # Get root_path return index view
  app.get '/', (req, resp) ->
    resp.render 'index'

  app.get '/about', (req, resp) ->
    resp.render 'about'

  app.get '/data', (req,resp) ->
    json = require '../data/techradar.json'
    resp.contentType 'text/json'
    resp.send json

  app.get '/game.appcache', (req,resp) ->
    resp.contentType "text/cache-manifest"
    resp.render 'appcache'
      now: timestamp

  app.resource('punters', require('./punter').resource(options))
  app

exports.server = server