###
  Markdown预处理器
###

# @nodoc
fs = require 'fs'
markdown = require('markdown').markdown
htmlparser = require 'htmlparser'

# Un-Rendered MarkDown
class URMD
  constructor: (@references, content) ->
    # 末尾追加引用生成
    @content = "#{content}\n<!-- 自动生成的引用 -->\n{{ genReferences() }}"
  
  # 设置键值对
  # @param key   {String}
  # @param value {Object}
  set: (key, value)->
    @[key] = value

# 预处理Markdown, 读取首部注释内的键值列表
# 
# @param path {String} 带渲染的Markdown文件的路径
# @return {URMD}
preprocess = (path) ->
  content = fs.readFileSync path, encoding: 'utf-8'
  handler = new htmlparser.DefaultHandler (err, dom) ->
  parser = new htmlparser.Parser handler
  md = markdown.parse(content)
  urmd = new URMD(md[1].references, content)
  try
    parser.parseComplete md[2][1]
    # TODO 更健壮的首部键值对解析
    pairs = handler.dom[0].data.trim().split('\n')
    for pair in pairs
      [key, value] = pair.split(': ')
      urmd.set key.trim().toLowerCase(), value.trim()
  catch err
  return urmd

# @nodoc
exports.URMD = URMD
exports.preprocess = preprocess
