require('coffee-script/register');
const pr = require('./src/pr');

function draw(name, label) {
  pr.immutable((err, symbols) =>
    console.log(drawClassDiagram(symbols.findOne({name}), label)));
}

function access(qualifier) {
  return qualifier == 'public' ? '+' : '-';
}

function $(s) {
  return s.replace(/_/g, '\\_');
}

function members(e) {
  const xs = e.members;
  let mem = [];
  let ops = [];
  for (let x of xs) {
    if (x.kind == 'variable') {
      let type = x.definition.substring(0, x.definition.length - x.fullname.length - 1);
      mem.push(`  ${access(x.access)} ${$(x.name)} : ${$(type)}`);
    }
    if (x.kind == 'function') {
      if (x.definition.indexOf(' ') == -1) {
        continue;
      }
      let type = x.definition.substring(0, x.definition.length - x.fullname.length - 1);
      ops.push(`  ${access(x.access)} ${$(x.name)} : ${$(type)}`);
    }
  }
  return [mem.join(" \\\\\n"), ops.join(" \\\\\n")];
}

function drawClassDiagram(e, label) {
  // console.log(e);
  let [mem, ops] = members(e);
  return `\\begin{figure}[H]
\\caption{类图 - ${e.name}}
\\label{${label}}
\\centering 
\\begin{tikzpicture}
\\umlclass{${e.name}}{
${mem}
  }{
${ops}
}
\\end{tikzpicture}
\\end{figure}
`;
}

draw("caffe::SyncedMemory", "fig:cls-mem");
draw("caffe::Blob",         "fig:cls-blob");
draw("caffe::Layer",        "fig:cls-layer");
draw("caffe::Net",          "fig:cls-net");
draw("caffe::Solver",       "fig:cls-slv");

  
