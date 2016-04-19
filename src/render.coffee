###
构造渲染Markdown用的Render
###

u = require 'underscore'
fs = require 'fs'
pr = require './pr'
util = require 'util'
swig = require 'swig'
async = require 'async'
preprocess = require('./preprocessor').preprocess

# @nodoc
sourceBase = 'https://github.com/BVLC/caffe/blob/master';
wikiBase = 'https://github.com/oopsno/caffe-insight/wikir';

# 生成符号表实体对应的Github链接
# @param entity {Object} 符号表实体
# @return {String}
sourceRef = (entity) ->
  "#{sourceBase}/#{entity.location.file}#L#{entity.location.line}"

# 生成符号表实体对应的Wiki页面的链接
# @param entity {Object} 符号表实体
# @return {String}
wikiRef = (entity) ->
  "#{wikiBase}/#{entity.location.file}#L#{entity.location.line}"

# 生成符号表实体到对应的文件的Github链接
# @param entity {Object} 符号对应的实体
# @return {String}
fileRef = (entity) ->
  return "#{sourceBase}/#{entity.location.file}"

# 渲染上下文
class RenderContext
  constructor: (@db, @manager) ->
    @refs = {}

# 生成符号到Github上源码对应位置的链接
# @example 如何在Markdown + Swig中使用
# {{ srcLink("caffe::Layer") }}
# @param symbol {String} qualified name
  srcLink: (symbol) ->
    e = @db.findOne name: symbol
    ref = "`#{e.name}`"
    if e.location
      switch e.kind
        when 'class' then @refs[ref] = "#{sourceRef e}"
        when 'file'  then @refs[ref] = "#{fileRef e}"
        else throw new TypeError "Cannot create srcLink on #{symbol}"
      return "[#{ref}]"
    else
      return ref

# 生成符号到Wiki上各个条目对应位置的链接
# @example 如何在Markdown + Swig中使用
# {{ wikiLink("caffe::Layer") }}
# @param symbol {String} qualified name
  wikiLink: (symbol) ->
    e = @db.findOne name: symbol
    if e.location
      "[`#{e.name}`](#{ e})"
    else "`#{e.name}`"

# 生成所有引用
  genReferences: ->
    ref = ""
    for name, url of @refs
      ref += "[#{name}]: #{url}\n"
    return ref

# 管理RenderContext, 生成文档的到文档的引用
class RenderContextManager
  # 无参数默认构造
  constructor: (@db) ->
    @contexts = {}

# 获取RenderContext
# @param name {URMD} Context的名字 同名的Context会被复用以支持多趟编译
  getContext: (urmd) ->
    name = urmd.$title || "anonymous"
    if not @contexts[name]
      ctx = new RenderContext @db, @
      u.extend(ctx, u.mapObject(ctx.__proto__, (value) -> value.bind(ctx)))
      u.extend(ctx, urmd)
      @contexts[name] = ctx
    return @contexts[name]

# 异步加载数据库并构造RenderManager
# @param callback {Function} (error, manager)
getManager = (callback) ->
  pr.immutable (err, db) ->
    if err
      callback err, null
    else
      callback null, new RenderContextManager db

# 渲染全部文件
render = (fileMap, callback) ->
  getManager (err, manager) ->
    try
      if err
        return callback err, null
      cache = {}
      # 初次渲染
      for src, target of fileMap
        urmd = preprocess src
        cache[src] = urmd
        context = manager.getContext urmd
        swig.render urmd.content, locals: context
      # 二次渲染
      for src, target of fileMap
        urmd = cache[src]
        context = manager.getContext urmd
        md = swig.render urmd.content, locals: context
        fs.writeFileSync target, md
      return callback null, fileMap
    catch error
      return callback error, src

# @nodoc
exports.render = render
