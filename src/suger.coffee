pr = require './pr'
swig = require 'swig'

sourceBase = 'https://github.com/BVLC/caffe/blob/master';

sourceRef = (entity) ->
  "#{sourceBase}/#{entity.location.file}#L#{entity.location.line}"

generateLocals = (callback) ->
  pr.immutable (err, symbols) ->
     generateLink = (symbol) ->
       e = symbols.findOne name: symbol
       if e.location
         "[`#{e.name}`](#{sourceRef e})"
       else "`#{e.name}`"
     callback null,
      gl: generateLink

exports.generateLocals = generateLocals
