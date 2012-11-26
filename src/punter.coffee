mongoose = require 'mongoose'
require 'express-mongoose'
{Promise} = mongoose
require './mongoose-pipe'
_ = require('underscore')

RegExp::bindMember = (name) ->
  @[name].bind @

Schema = mongoose.Schema

resource = ( options ) ->
  {db} = options

  unless db
    console.log("Skipping punters")
    return {}

  console.log("Constructing schema")
  GameSchema = new Schema
    score:
      type: Number
      default: 0
    timestamp:
      type: Date
      default: Date.now
  PunterSchema = new Schema
    fullName:
      type: String
      required: true
    company:
      type: String
      required: true
    role:
      type: String
      required: true
    emailAddress: String
    game: [GameSchema]
  PunterSchema.virtual('score')
  .get ->
    this.game?[0]?.score ? null
  PunterSchema.virtual('scoreTime')
  .get ->
    this.game?[0]?.timestamp ? null

  PunterModel = db.model "punters", PunterSchema

  NoModelFound = new Promise().error('No model found')

  firstModel = (arr) ->
    arr?[0] || NoModelFound

  invalidModelKey = /^_/.bindMember 'test'

  hasInvalidModelKey = (body) ->
    _.chain(body)
    .keys()
    .any(invalidModelKey)
    .value()

  allow = (req, res, next)->
    next()

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

  index =
    csv: (req,res) ->
      res.header 'content-type','text/csv'
      res.header 'content-disposition', 'attachment; filename=report.csv'
      res.write "Email, Full Name, Company, Role, Score, Time\r\n"
      docStream = PunterModel.find().sort({scoreTime:-1}).stream()
      docStream.on 'data', (doc) ->
        res.write "#{doc.emailAddress},#{doc.fullName},#{doc.company},#{doc.role},#{doc.score},#{doc.scoreTime}\r\n"
      docStream.on 'close', ->
        res.end()


  create = (req, resp) ->
    unless req.body
      return resp.send 400, 'No content'

    if hasInvalidModelKey req.body
      return resp.send 400, 'Invalid model'

    punter = new PunterModel req.body

    promise = new Promise()

    promise.pipe (p) ->
      resp.redirect "#{req.url}/#{p._id}"
    , (err) ->
      resp.send 400, err

    punter.save promise.resolver()

  resource =
    load: load
    show: show
    create: create
    index: index

exports.resource = resource
