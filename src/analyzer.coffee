_ = require 'underscore'
fs = require 'fs'
pr = require './pr'
path = require 'path'
async = require 'async'
grunt = require 'grunt'
model = require './model.coffee'
parser = require './parser.coffee'

xmlRoot = path.resolve 'caffe/doxygen/xml'

indexInfo = (i) -> _.extend {name: i.name}, i['$']

targetKind = new Set([
  "class"
  "file"
])

analyzeDocWith = (step) -> (path, callback) ->
  async.waterfall [
    (cb) -> fs.readFile path, cb            # read
    (xml, cb) -> parser.parseString xml, cb # parse XML
    step                                    # do-staff
  ], callback

analyzeIndex = (cb) -> (analyzeDocWith (doc, cb) -> cb null,
  doc.doxygenindex.compound.map (c) ->   # take name, kind, refid
    _.extend indexInfo c, members: _.map c.member || [], indexInfo
  .filter (item) -> item.kind != 'dir'   # remove 'dir's
 ) "#{xmlRoot}/index.xml", cb

fileInIndex = (index) ->
  (index.filter (i) -> targetKind.has i.kind)
    .map (i) -> "#{xmlRoot}/#{i.refid}.xml"

analyzeFile = (f, cb) -> cb null, new model.File f
analyzeCompound = (c, cb) -> cb null, new model.Compound c
analyzeXML = analyzeDocWith (doc, cb) ->
  r = doc.doxygen.compounddef
  switch r['$'].kind
    when "class" then analyzeCompound r, cb
    when "file"  then analyzeFile r, cb

analyzeSymbols = (callback) ->
  async.waterfall [
    analyzeIndex
    (i, cb) -> async.map (fileInIndex i), analyzeXML, cb
  ], callback

analyze = (callback) ->
  pr.initialize (prErr, symbols, sync) ->
    analyzeSymbols (symErr, xs) ->
      symbols.insert xs
      sync (-> callback null, pr.filename)

exports.fileInIndex = fileInIndex
exports.analyzeCompound = analyzeCompound
exports.analyzeFile = analyzeFile
exports.analyzeIndex = analyzeIndex
exports.analyzeXML = analyzeXML
exports.analyze = analyze
