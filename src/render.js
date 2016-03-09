var fs = require('fs');
var swig = require('swig');
var async = require('async');
var insight = require('./caffe-insight');

function getRender(callback) {
  insight.generateLocals(function (err, locals) {
    function render(src, dest, callback) {
      async.waterfall([
        fs.readFile.bind(this, src, {encoding: 'utf-8'}),
        function (contents, callback) {
          const rendered = swig.render(contents, {locals: locals});
          return callback(null, rendered);
        },
        fs.writeFile.bind(this, dest)
      ], callback);
    }

    callback(null, render);
  });
}

exports.getRender = getRender;
