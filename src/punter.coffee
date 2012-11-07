mongoose = require 'mongoose'
require 'express-mongoose'
{Promise} = mongoose
require './mongoose-pipe'


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

NoModelFound = new Promise().error('No model found')

firstModel = (arr) -> 
  arr?[0] || NoModelFound

load = (id, next)->
  PunterModel
  .find
    _id: id
  .exec()
  .pipe(firstModel)
  .addBack next

show = (req, resp) ->
  if req.punter
    resp.send 200, req.punter
  else
    resp.send 404, { message: "No model found" }
  
create = (req, resp) ->
  unless req.body
    return resp.send 400, 'No content'

  punter = new PunterModel()
  punter.fullName = req.body.fullName
  punter.company = req.body.company
  punter.emailAddress = req.body.emailAddress

  promise = new Promise()

  promise.pipe (p) -> 
    resp.redirect "#{req.url}/#{p._id}"
  , (err) -> 
      resp.send 400, err

  punter.save promise.resolver()

exports.load = load
exports.show = show
exports.create = create