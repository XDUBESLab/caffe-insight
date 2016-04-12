###
  Markdown预处理器
###

# @nodoc
fs = require 'fs'
yaml = require 'yaml'

# Un-Rendered MarkDown
class URMD
  constructor: (content) ->
    # 末尾追加引用生成
    @content = "#{content}\n<!-- 自动生成的引用 -->\n{{ genReferences() }}"
  
  # 设置键值对
  # @param key   {String}
  # @param value {Object}
  set: (key, value)->
    @["$#{key}"] = value

# 预处理Markdown, 读取首部注释内的键值列表
# 
# @param path {String} 带渲染的Markdown文件的路径
# @return {URMD}
preprocess = (path) ->
  content = fs.readFileSync path, encoding: 'utf-8'
  urmd = new URMD(content)
  try
    header = yaml.eval content.split('---')[0]
    for key, value of header
      urmd.set key, value
  catch err
  return urmd

# @nodoc
exports.URMD = URMD
exports.preprocess = preprocess
