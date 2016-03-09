var loki = require('lokijs');
var grunt = require('grunt');
const localJson = 'symbols.json';
const collectionSymbols = 'symbols';

exports.immutable = function (callback) {
  var db = new loki(localJson);
  db.loadDatabase(function (err, data) {
    callback(null, db.getCollection(collectionSymbols));
  });
};

exports.initialize = function (callback) {
  var db = new loki(localJson);
  var symbols = db.addCollection(collectionSymbols, {indices: ['qualifiedName', 'refid']});
  var sync = function (callback) {
    db.saveDatabase(callback);
  };
  return callback(null, symbols, sync);
};

exports.filename = localJson;
