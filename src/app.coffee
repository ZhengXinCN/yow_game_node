express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
resource = require 'express-resource'

app = express()
# Add Connect Assets
app.use assets()
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

app.resource('punters', require('./punter'))

exports.app = app