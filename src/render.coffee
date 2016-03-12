fs = require 'fs'
swig = require 'swig'
async = require 'async'
insight = require './suger.coffee'

getRender = (callback) ->
  insight.generateLocals (err, locals) ->
    render = (src, dest, callback) ->
      async.waterfall [
        fs.readFile.bind this, src, encoding: 'utf-8'
        (contents, callback) ->
          rendered = swig.render(contents, {locals: locals})
          return callback(null, rendered)
        fs.writeFile.bind(this, dest)
      ], callback

    callback(null, render)

exports.getRender = getRender
