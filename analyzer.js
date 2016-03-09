/**
 * 分析Doxygen生成的XML输出以索引符号
 */

'use strict';

var xml2js = require('xml2js');
var async = require('async');
var loki = require('lokijs');
var fs = require('fs');
var grunt = require('grunt');
var _ = require('underscore');

const targetKinds = new Set([
  "class", "variable", "function", "typedef"
]);
const xmlRoot = 'caffe/doxygen/xml/';

var db = new loki('symbols.json');
var symbols = db.addCollection('symbols');

class CompoundIndex {
  constructor(obj) {
    const attr = obj['$'];
    this.qualifiedName = obj.name;
    this.kind = attr.kind;
    this.refid = attr.refid;
    this.members = (obj.member || []).map(function (c) {
      return new MemberIndex(attr.name, c);
    });
  }

  relpath() {
    return this.refid + '.xml';
  }
}

class MemberIndex extends CompoundIndex {
  constructor(parent, obj) {
    super(obj);
    this.qualifiedName = parent + '::' + this.qualifiedName;
  }

  relpath() {
    return this.refid.substr(0, this.refid.length - 35) + '.xml';
  }
}

class MemeberRefence {
  constructor(qualifiedName, ref) {
    const attr = ref['$'];
    this.refid = attr.refid;
    this.protectionKink = attr.prot;
    this.virtual = attr.virt === 'virtual';
    this.qualifiedName = qualifiedName;
  }
}

class Index {
  constructor(obj) {
    const objs = obj.doxygenindex.compound;
    this.compounds = objs.map(function (c) {
      return new CompoundIndex(c);
    }).filter(function (ci) {
      return targetKinds.has(ci.kind);
    });
    this.size = this.compounds.length;
  }
}

class MemberDef {
  constructor(parent, obj) {
    const attr = obj['$'];
    this.qualifiedName = parent + '::' + attr.name;
    this.kind = attr.kind;
    this.refid = attr.id;
    this.protected = attr.prot === 'yes';
    this.static = attr.static === 'yes';
    this.mutable = attr.mutable === 'yes';
    this.type = obj.type;
    this.definition = obj.definition;
    this.location = obj.location[0]['$'];
  }
}

class CompoundDef {
  constructor(obj) {
    const compounddefs = obj.doxygen.compounddef;
    if (Array.isArray(compounddefs) && compounddefs.length === 1) {
      const compounddef = compounddefs[0];
      const name = compounddef.compoundname;
      this.refid = compounddef['$'].id;
      this.kind = compounddef['$'].kind;
      this.qualifiedName = name;
      this.location = compounddef.location['$'];
      this.memberRefs = compounddef.listofallmembers[0].member.map(function (mr) {
        return _.zip(mr.scope, mr.name).map(function (pair) {
          return pair.join('::');
        }).map(function (qn) {
          return new MemeberRefence(qn, mr);
        });
      }).reduce(function (p, c) {
        return p.concat(c);
      });
      this.members = compounddef.sectiondef.map(function (sec) {
        return sec.memberdef.map(function (m) {
          return new MemberDef(name, m);
        })
      }).reduce(function (p, c) {
        return p.concat(c);
      }, []);
    } else {
      grunt.log.error('Parser Error');
    }
  }
}

function parseXML(abspath, callback) {
  async.waterfall([
      fs.readFile.bind(this, abspath, null),
      xml2js.parseString
    ],
    callback);
}

function processIndex(doc, callback) {
  grunt.log.write('Processing index...');
  var index = new Index(doc);
  grunt.log.ok();
  grunt.log.writeln('Compounds: ' + index.size);
  callback(null, index);
}

function parseIndex(abspath, callback) {
  async.waterfall([
      parseXML.bind(this, abspath),
      processIndex
    ],
    callback)
}

function loadCompound(compound, callback) {
  async.waterfall([
    fs.readFile.bind(this, xmlRoot + compound.relpath()),
    xml2js.parseString,
    function (obj, callback) {
      callback(null, new CompoundDef(obj));
    }
  ], callback);
}

function loadCompounds(index, callback) {
  async.map(index.compounds, loadCompound, function (err, compunds) {
    callback(null, index, compunds);
  });
}

async.waterfall([
  parseIndex.bind(this, xmlRoot + 'index.xml'),
  function (index, callback) {
    grunt.log.write('Loading compounds...');
    callback(null, index);
  },
  loadCompounds,
  function (index, compounds, callback) {
    grunt.log.ok();
    grunt.log.writeln('Compounds loaded: ' + compounds.length);
    grunt.log.writeln('Member references loaded: ' + compounds.reduce(function (p, c) {
        return p + c.memberRefs.length;
      }, 0));
    grunt.log.writeln('Members loaded: ' + compounds.reduce(function (p, c) {
        return p + c.members.length;
      }, 0));
    callback(null, index, compounds);
  },
  function (index, compounds) {
    grunt.log.write('Flattening references...');
    compounds.forEach(function (c) {
      symbols.insert(c);
      c.members.forEach(function (mr) {
        symbols.insert(mr);
      });
    });
    grunt.log.ok();
    grunt.log.write('Saving Database...');
    db.save();
    grunt.log.ok();
  }]);

module.exports = parseXML;

