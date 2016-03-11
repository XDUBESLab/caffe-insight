require 'coffee-script'

fs = require 'fs'
path = require 'path'
render = require './src/render'
analyzer = require './src/analyzer.coffee'
prettysize = require 'filesize'

analyze = analyzer.analyze

projectRoot = __dirname
wikiRepo = 'https://github.com/XDUBESLab/caffe-insight.wiki.git'
caffeRepo = 'https://github.com/BVLC/caffe.git'
wikiLocal = path.join projectRoot, 'caffe-insight-wiki'
caffeLocal = path.join projectRoot, 'caffe'
draftLocal = path.join projectRoot, 'draft'
renderedLocal = path.join projectRoot, 'rendered'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-git'
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    gitclone:
      wiki:
        options:
          repository: wikiRepo
          directory: wikiLocal
      caffe:
        options:
          repository: caffeRepo
          directory: caffeLocal

  grunt.registerTask 'usage', ->
    grunt.log.subhead 'Usage:\tgrunt [render | sync | test]'

  grunt.registerTask 'sync', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'test', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'init:caffe', ->
    grunt.log.write 'Loiking for Caffe...'
    if !grunt.file.exists caffeLocal
      grunt.log.writeln 'Caffe not found. Cloning from #{caffeRepo}'
      grunt.task.run 'gitclone:caffe'
    else
      grunt.log.ok

  grunt.registerTask 'init:wiki', ->
    grunt.log.write 'Cloning Wiki...'
    if grunt.file.exists wikiLocal
      grunt.file.delete wikiLocal
    grunt.task.run 'gitclone:wiki'

  grunt.registerTask 'init', ['init:caffe', 'init:wiki']

  grunt.registerTask 'index', ->
    this.async()
    analyze (err, dbFilename) ->
      fileszie = fs.statSync(dbFilename).size
      grunt.log.ok '#{prettysize(fileszie)} (#{fileszie} Bytes) written.'

  grunt.registerTask 'render', ->
    this.async()
    render.getRender (err, render) ->
      grunt.log.writeln 'Rendering drafts...'
      grunt.file.recurse draftLocal, (src, rootdir, subdir, filename) ->
        dest = path.join renderedLocal, filename
        render src, dest, (err, data) ->
          if err
            grunt.log.error err, data
            grunt.log.error 'Cannot render: #{src}'
          else
            grunt.log.ok 'Rendered: #{src}'

  grunt.registerTask 'default', 'usage'
