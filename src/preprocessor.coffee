###
  Markdown预处理器
###

# @nodoc
fs = require 'fs'
markdown = require('markdown').markdown
htmlparser = require 'htmlparser'

# 预处理Markdown, 读取首部注释内的键值列表
# 
# @param path {String} 带渲染的Markdown文件的路径
preprocess = (path) ->
  content = fs.readFileSync path, encoding: 'utf-8'
  handler = new htmlparser.DefaultHandler (err, dom) ->
  parser = new htmlparser.Parser handler
  md = markdown.parse(content)
  properties =
    refs: md[1].references
    raw: content
  try
    parser.parseComplete md[2][1]
    pairs = handler.dom[0].data.trim().split('\n')
    for pair in pairs
      [key, value] = pair.split(':', 2)
      properties[key.trim()] = value.trim()
  catch err
  return properties

exports.preprocess = preprocess
