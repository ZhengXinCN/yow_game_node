express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
require 'express-mongoose'

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

app.get '/result', (req,resp) ->
  resp.render 'result'

mongoose = require 'mongoose'
db_url = process.env.MONGOLAB_URL || "mongodb://localhost//yow_game"
db = mongoose.connect db_url
Schema = mongoose.Schema

PunterSchema = new Schema
  fullName: 
    type: String
    required: true
  company: 
    type: String
    required: true

  emailAddress: String

PunterModel = db.model "punters", PunterSchema

app.get '/punters/:id', (req, resp)->
  resp.send PunterModel.find 
    _id: req.param('id')

app.post '/punters', (req, resp) ->
  unless /application\/json/.test req.headers['content-type']
    return resp.send 400, 'Unsupported content-type'

  unless req.body
    return resp.status 400, 'No content'

  punter = new PunterModel()
  punter.fullName = req.body.fullName
  punter.company = req.body.company
  punter.emailAddress = req.body.emailAddress

  punter.save (err, punter)->
    if err
      resp.send 400, err
    else 
      resp.redirect "punters/#{punter._id}"


port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
