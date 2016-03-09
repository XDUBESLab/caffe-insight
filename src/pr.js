var loki = require('lokijs');

var db = new loki('symbols.json');
var symbols = db.addCollection('symbols');

exports.db = db;
exports.symbols = symbols;
exports.filename = db.filename;
exports.sync = function () {
  db.save();
};

