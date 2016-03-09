var loki = require('lokijs');
var grunt = require('grunt');
var path = require('path');
const localJson = path.resolve(__dirname, '../symbols.json');
const collectionSymbols = 'symbols';

exports.immutable = function (callback) {
  var db = new loki(localJson);
  db.loadDatabase({}, function (err, data) {
    if (err !== null) {
      grunt.log.error(err, data);
    } else {
      callback(null, db.getCollection(collectionSymbols));
    }
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

exports.count = function (collection) {
  return collection.mapReduce(function () {
    return 1;
  }, function (array) {
    return array.reduce(function (p, c) {
      return p + c;
    }, 0);
  });
};

exports.filename = localJson;
