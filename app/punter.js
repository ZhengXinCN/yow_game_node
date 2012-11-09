// Generated by CoffeeScript 1.4.0
var Promise, Schema, mongoose, resource, _;

mongoose = require('mongoose');

require('express-mongoose');

Promise = mongoose.Promise;

require('./mongoose-pipe');

_ = require('underscore');

RegExp.prototype.bindMember = function(name) {
  return this[name].bind(this);
};

Schema = mongoose.Schema;

resource = function(options) {
  var NoModelFound, PunterModel, PunterSchema, create, db, firstModel, hasInvalidModelKey, invalidModelKey, load, show;
  db = options.db;
  if (!db) {
    return {};
  }
  PunterSchema = new Schema({
    fullName: {
      type: String,
      required: true
    },
    company: {
      type: String,
      required: true
    },
    emailAddress: String
  });
  PunterModel = db.model("punters", PunterSchema);
  NoModelFound = new Promise().error('No model found');
  firstModel = function(arr) {
    return (arr != null ? arr[0] : void 0) || NoModelFound;
  };
  invalidModelKey = /^_/.bindMember('test');
  hasInvalidModelKey = function(body) {
    return _.chain(body).keys().any(invalidModelKey).value();
  };
  load = function(id, next) {
    return PunterModel.find({
      _id: id
    }).exec().pipe(firstModel).addBack(next);
  };
  show = function(req, resp) {
    if (req.punter) {
      return resp.send(200, req.punter);
    } else {
      return resp.send(404, {
        message: "No model found"
      });
    }
  };
  create = function(req, resp) {
    var promise, punter;
    if (!req.body) {
      return resp.send(400, 'No content');
    }
    if (hasInvalidModelKey(req.body)) {
      return resp.send(400, 'Invalid model');
    }
    punter = new PunterModel(req.body);
    promise = new Promise();
    promise.pipe(function(p) {
      return resp.redirect("" + req.url + "/" + p._id);
    }, function(err) {
      return resp.send(400, err);
    });
    return punter.save(promise.resolver());
  };
  return resource = {
    load: load,
    show: show,
    create: create
  };
};

exports.resource = resource;
