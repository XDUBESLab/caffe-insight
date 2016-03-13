_ = require 'underscore'

many = (cls, arg) ->
  cons = (i) -> if arg then new cls i, arg else new cls i
  (obj) -> if Array.isArray obj then obj.map cons else [cons obj]

manyMap = (fn) -> (obj) ->
  if Array.isArray obj then obj.map fn else [fn obj]

any = (obj) ->
  if Array.isArray obj then obj else [obj]

class Indexable
  constructor: (@name, @refid, @kind) ->
  sep: '::'
  slugs: => name.split sep

mergeInclude = (i) -> _.extend (path: i['_']), i['$']

class File extends Indexable
  constructor: (doc) ->
    attr = doc['$']
    super doc.compoundname, attr.id, attr.kind
    @includes = (manyMap mergeInclude) (doc.includes || [])
    @includedBy = (manyMap mergeInclude) (doc.includedby || [])

class Import extends Indexable
  constructor: (doc) ->
    @basename = doc['_']
    @refid = doc['$'].refid
    @local = doc['$'].local == 'yes'

  relPath: => "#{@basename}.xml"

class Member extends Indexable
  constructor: (def, parent) ->
    attr = def['$']
    super "#{parent}::#{def.name}", def.refid, attr.kind
    @prot = attr.prot
    @static = attr.static
    @mutable = attr.mutable

class Compound extends Indexable
  constructor: (def) ->
    attr = def['$']
    name = def.compoundname
    super name, attr.id, attr.kind
    @prot = attr.prot
    @location = def.location['$']
    @imports = (many Import) (def.imports || [])
    members = {}
    (any def.sectiondef).forEach (sec) ->
      members[sec['$']['kind']] = (many Member, name) (sec.memberdef || [])
    @members = members

exports.File = File
exports.Import = Import
exports.Member = Member
exports.Compound = Compound
