mongoose = require 'mongoose'

port = process.env.PORT or process.env.VMC_APP_PORT or 3000

db_url = process.env.MONGOLAB_URL || "mongodb://localhost//yow_game"

with_db = (db) ->
  options =
    db: db

  console.log options
  # Start Server
  require('./app').server(options).listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."

db = mongoose.connect db_url

db.connections[0].once 'open', ->
  with_db db
db.connections[0].on 'error', ->
  with_db null


