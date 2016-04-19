require 'coffee-script'

fs = require 'fs-extra'
path = require 'path'
render = require './src/render.coffee'
analyzer = require './src/analyzer.coffee'
prettysize = require 'filesize'

analyze = analyzer.analyze

projectRoot = __dirname
wikiRepo = 'https://github.com/XDUBESLab/caffe-insight.wiki.git'
caffeRepo = 'https://github.com/BVLC/caffe.git'
wikiLocal = path.join projectRoot, 'caffe-insight-wiki'
caffeLocal = path.join projectRoot, 'caffe'
draftLocal = path.join projectRoot, 'draft'
renderedLocal = path.join projectRoot, 'hexo/source/_posts'
hexoLocal = 'hexo'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-git'
  grunt.loadNpmTasks 'grunt-hexo'
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
    hexo:
      clean:
        options:
          root: hexoLocal
          cliCmd: 'clean'
      generate:
        options:
          root: hexoLocal
          cliCmd: 'generate'
      deploy:
        options:
          root: hexoLocal
          cliCmd: 'deploy'
      server:
        options:
          root: hexoLocal
          cliCmd: 'server'

  grunt.registerTask 'usage', ->
    grunt.log.subhead 'Usage:\tgrunt [render | sync | test]'

  grunt.registerTask 'sync', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'test', ->
    grunt.log.errorlns 'Not Implemented Yet'

  grunt.registerTask 'init:caffe', ->
    grunt.log.write 'Loiking for Caffe...'
    if !grunt.file.exists caffeLocal
      grunt.log.writeln "Caffe not found. Cloning from #{caffeRepo}"
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
      grunt.log.ok "#{prettysize(fileszie)} (#{fileszie} Bytes) written."

  grunt.registerTask 'render', ->
    this.async()
    fs.ensureDirSync renderedLocal
    drafts = fs.readdirSync draftLocal
    fileMap = {}
    for draft in drafts
      if path.parse(draft).base.match(/\w+\.md$/)
        fileMap[path.join draftLocal, draft] = path.join renderedLocal, draft
        grunt.log.ok("Source found: #{draft}")
      else
        grunt.log.debug("Passing #{draft}...")
    render.render fileMap, (err, rendered) ->
      if err
        grunt.log.error("Cannot render #{rendered}")
        grunt.log.error(err.stack)
      else
        for src, target of rendered
          grunt.log.ok("Rendered: #{path.relative process.cwd(), src}")

  grunt.registerTask 'r', 'render'
  grunt.registerTask 'g', 'hexo:generate'
  grunt.registerTask 's', 'hexo:server'

  grunt.registerTask 'default', 'usage'
