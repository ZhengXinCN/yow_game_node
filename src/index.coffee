express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'

app = express()
# Add Connect Assets
app.use assets()
# Set the public folder as static assets
app.use express.static(process.cwd() + '/public')
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
	fullName: String
	company: String
	emailAddress: String

PunterModel = db.model "punters", PunterSchema

app.get '/punters/:id', (req, resp)->
	PunterModel.find
	  	_id: req.param('id')
	,(err, punter) -> 
		resp.send 200, punter

app.post '/punters', (req, resp) ->
	punter = new PunterModel
	punter.fullName = "Mr Unknowable"
	punter.company = "ThoughtWorks"
	punter.emailAddress = "someone@somewhere"
	punter.save()

	resp.redirect "punters/#{punter._id}"

port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
