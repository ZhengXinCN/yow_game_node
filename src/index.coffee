mongoose = require 'mongoose'

port = process.env.PORT or process.env.VMC_APP_PORT or 3000

db_url = process.env.MONGOLAB_URL || "mongodb://localhost//yow_game"

with_db = (db) ->
  options =
    db: db

  console.log options
  # Start Server
  require('./app').server(options).listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."

mongoose.connect db_url
with_db mongoose

