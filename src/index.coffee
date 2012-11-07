
port = process.env.PORT or process.env.VMC_APP_PORT or 3000
# Start Server
require('./app').app.listen port, -> console.log "Listening on #{port}\nPress CTRL-C to stop server."
