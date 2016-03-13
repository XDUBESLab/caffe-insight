_ = require 'underscore'
loki = require 'lokijs'
path = require 'path'
grunt = require 'grunt'
localJson = path.resolve __dirname, '../symbols.json'
collectionSymbols = 'symbols'

immutable = (callback) ->
  db = new loki localJson
  db.loadDatabase {}, (result) ->
    if _.isError result
      grunt.log.error "Cannot load local database at #{localJson}: #{result}"
      callback result, null
    else
      callback null, db.getCollection(collectionSymbols)

initialize = (callback) ->
  db = new loki localJson
  symbols = db.addCollection collectionSymbols, indices: ['name', 'refid']
  sync = (callback) -> db.saveDatabase callback
  callback null, symbols, sync

exports.immutable = immutable
exports.initialize = initialize
exports.filename = localJson


