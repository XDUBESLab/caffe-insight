wiki_repo = 'https://github.com/XDUBESLab/caffe-insight.wiki.git'
wiki_local = 'caffe-insight-wiki'
caffe_repo = 'https://github.com/BVLC/caffe.git'
caffe_local = 'caffe'
draft_local = 'draft'
rendered_local = 'rendered'

fs = require 'fs'
path = require 'path'
render = require './src/render'
analyze = require './src/analyzer'
prettysize = require 'filesize'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-git'
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    gitclone:
      wiki:
        options:
          repository: wiki_repo
          directory: wiki_local
      caffe:
        options:
          repository: caffe_repo
          directory: caffe_local

  grunt.registerTask 'usage', ->
    grunt.log.subhead 'Usage:\tgrunt [render | sync | test]'

  grunt.registerTask 'sync', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'test', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'init:caffe', ->
    grunt.log.write 'Loiking for Caffe...'
    if !grunt.file.exists caffe_local
      grunt.log.writeln 'Caffe not found. Cloning from #{caffe_repo}'
      grunt.task.run 'gitclone:caffe'
    else
      grunt.log.ok

  grunt.registerTask 'init:wiki', ->
    grunt.log.write('Cloning Wiki...');
    if grunt.file.exists wiki_local
      grunt.file.delete wiki_local
    grunt.task.run 'gitclone:wiki'

  grunt.registerTask 'init', ['init:caffe', 'init:wiki']
  grunt.registerTask 'index', ->
    this.async
    analyze (err, dbFilename) ->
      fileszie = fs.statSync(dbFilename).size
      grunt.log.ok '#{prettysize(fileszie)} (#{fileszie} Bytes) written.'

  grunt.registerTask 'render', ->
    this.async
    render.getRender (err, render) ->
      grunt.log.writeln 'Rendering drafts...'
      grunt.file.recurse draft_local, (src, rootdir, subdir, filename) ->
        dest = path.join rendered_local, filename
        render src, dest, (err, data) ->
          if err
            grunt.log.error err, data
            grunt.log.error 'Cannot render: #{src}'
          else
            grunt.log.ok 'Rendered: #{src}'

  grunt.registerTask 'default', 'usage'
