const wiki_repo = 'https://github.com/XDUBESLab/caffe-insight.wiki.git';
const wiki_local = 'caffe-insight-wiki';
const caffe_repo = 'https://github.com/BVLC/caffe.git';
const caffe_local = 'caffe';
const draft_local = 'draft';
const rendered_local = 'rendered';

var fs = require('fs');
var path = require('path');
var render = require('./src/render');
var analyze = require('./src/analyzer');
var prettysize = require('filesize');

module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-git');
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    gitclone: {
      wiki: {
        options: {
          repository: wiki_repo,
          directory: wiki_local
        }
      },
      caffe: {
        options: {
          repository: caffe_repo,
          directory: caffe_local
        }
      }
    }
  });
  grunt.registerTask('usage', function () {
    grunt.log.subhead('Usage:\tgrunt [render | sync | test]');
  });
  grunt.registerTask('sync', function () {
    grunt.log.errorlns('Not Implemented Yet');
  });
  grunt.registerTask('test', function () {
    grunt.log.errorlns('Not Implemented Yet');
  });
  grunt.registerTask('init:caffe', function () {
    grunt.log.write('Loiking for Caffe...');
    if (!grunt.file.exists(caffe_local)) {
      grunt.log.writeln('Caffe not found. Cloning from ' + caffe_repo);
      grunt.task.run('gitclone:caffe');
    } else {
      grunt.log.ok();
    }
  });
  grunt.registerTask('init:wiki', function () {
    grunt.log.write('Cloning Wiki...');
    if (grunt.file.exists(wiki_local)) {
      grunt.file.delete(wiki_local);
    }
    grunt.task.run('gitclone:wiki');
  });
  grunt.registerTask('init', ['init:caffe', 'init:wiki']);
  grunt.registerTask('index', function () {
    this.async();
    analyze(function (err, dbFilename) {
      const fileszie = fs.statSync(dbFilename).size;
      grunt.log.ok(prettysize(fileszie) + ' (' + fileszie + ' Bytes) written.');
    });
  });
  grunt.registerTask('render', function () {
    this.async();
    //if (!grunt.file.exists(rendered_local)) {
    //  grunt.file.mkdir(rendered_local);
    //}
    render.getRender(function (err, render) {
      grunt.log.writeln('Rendering drafts...');
      grunt.file.recurse(draft_local, function (src, rootdir, subdir, filename) {
        const dest = path.join(rendered_local, filename);
        render(src, dest, function (err, data) {
          if (err) {
            grunt.log.error(err, data);
            grunt.log.error('Cannot render: ' + src);
          } else {
            grunt.log.ok('Rendered: ' + src);
          }
        })
      });
    });
  });
  grunt.registerTask('default', 'usage');
};
