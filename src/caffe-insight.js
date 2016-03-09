var pr = require('./pr');
var swig = require('swig');

const sourceBase = 'https://github.com/BVLC/caffe/blob/master/';

function sourceRef(entity) {
  return sourceBase + entity.location.file + '#L' + entity.location.line;
}

function render(tpl, entity) {
  return swig.render(tpl, {
    locals: {
      e: entity,
      srcRef: sourceRef
    }
  });
}

exports.generateLocals = function (callback) {
  pr.immutable(function (err, symbols) {
    function generateLink(symbol) {
      var entity = symbols.findOne({'qualifiedName': symbol});
      if (entity.location) {
        return render('[`{{ e.qualifiedName }}`]({{ srcRef(e) }})', entity);
      } else {
        return render('`{{ e.qualifiedName }}`', entity);
      }
    }

    return callback(null, {
      'gl': generateLink
    });
  });
};
