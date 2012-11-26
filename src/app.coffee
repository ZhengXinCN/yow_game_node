
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
  passport = require 'passport'
  GoogleStrategy = require('passport-google').Strategy
  resource = require 'express-resource'
  _ = require "underscore"

  timestamp = Date.now()

  passport.serializeUser (user, done)->
    done(null, user)

  passport.deserializeUser (obj, done)->
    done(null, obj)

  passport.use new GoogleStrategy
    returnURL: "#{options.secure_realm}auth/google/return"
    realm: "#{options.secure_realm}"
  , (identifier, profile, done)->
    process.nextTick ->
      profile.identifier = identifier
      done(null,profile)

  ensureAuthenticated = (req, res, next) ->
    return next() if req.isAuthenticated()
    res.send 401, 'Please authenticate <a href="' + options.secure_realm + 'auth/google">here</a>'

  ensureAdministrator = (req,res,next)->
    isThoughtWorker = _.chain( req.user?.emails || [])
    .pluck( 'value')
    .any (email) ->
      /@thoughtworks.com$/.test(email)
    .value()

    return next() if isThoughtWorker
    res.send 403, 'Please contact the administrator for access'

  app = express()

  app.use express.cookieParser()
  app.use express.session
    secret: "wibble wobbly"

  # Add Connect Assets
  app.use assets()

  assetize_javascript_for_requirejs assets

   # Set the public folder as static assets
  app.use express.static(process.cwd() + '/public')



  app.use express.bodyParser()

  app.use passport.initialize()
  app.use passport.session()


  # Set View Engine
  app.set 'view engine', 'jade'
  # Get root_path return index view
  app.get '/', (req, resp) ->
    resp.render 'index'

  app.get '/about', (req, resp) ->
    resp.render 'about'

  app.get '/terms', (req, resp) ->
    resp.render 'terms'

  app.get '/data', (req,resp) ->
    json = require '../data/techradar.json'
    resp.contentType 'text/json'
    resp.send json

  app.get '/game.appcache', (req,resp) ->
    resp.contentType "text/cache-manifest"
    resp.render 'appcache'
      now: timestamp

  app.get '/auth/google', passport.authenticate('google', {failureRedirect: '/login'}), (req,res) ->
    res.redirect '/~'

  app.get '/auth/google/return', passport.authenticate('google', {failureRedirect: '/login'}), (req,res)->
    res.redirect '/~'

  app.get '/~', ensureAuthenticated, (req,res)->
    res.send "Hi me"

  app.get '/login', (req,res)->
    res.render 'login'

  app.get '/punters.:format?', ensureAuthenticated
  app.get '/punters.:format?', ensureAdministrator


  app.resource 'punters', require('./punter').resource(options)

  app

exports.server = server