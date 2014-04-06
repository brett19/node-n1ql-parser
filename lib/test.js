"use strict";

var fs = require('fs');
var util = require('util');

var N1qlParser = require('./main');


var t = new N1qlParser();
var q = fs.readFileSync(__dirname + '/../test.n1ql', 'utf8');
var stmt = t.parse(q);

console.log('PARSE STACK', util.inspect(t.parser.yy.pStack, {depth:10}));
console.log('PARSE STMT', util.inspect(stmt, {depth:10}));