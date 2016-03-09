const wiki_repo = 'https://github.com/XDUBESLab/caffe-insight.wiki.git';
const wiki_local = 'caffe-insight-wiki';
const caffe_repo = 'https://github.com/BVLC/caffe.git';
const caffe_local = 'caffe';
var analyze = require('./analyzer');
var fs = require('fs');

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
    analyze(function (err, dbfilename) {
      const fileszie = fs.statSync(dbfilename).size;
      grunt.log.ok('' + fileszie + ' Bytes written.');
    });
  });
  grunt.registerTask('default', 'usage');
};
