// Generated by CoffeeScript 1.4.0
var db_url, mongoose, port, with_db;

mongoose = require('mongoose');

port = process.env.PORT || process.env.VMC_APP_PORT || 3000;

db_url = process.env.MONGOLAB_URI || "mongodb://localhost//yow_game";

with_db = function(db) {
  var options;
  options = {
    db: db,
    secure_realm: process.env.APP_HOSTNAME != null ? "https://" + process.env.APP_HOSTNAME + "/" : "http://localhost:" + port + "/"
  };
  return require('./app').server(options).listen(port, function() {
    return console.log("Listening on " + port + "\nPress CTRL-C to stop server.");
  });
};

mongoose.connect(db_url);

with_db(mongoose);
