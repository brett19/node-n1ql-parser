"use strict";

var ast = require('./ast');

var Parser = require('./n1ql.gen').Parser;


function N1qlParser() {
  this.parser = new Parser();
}

N1qlParser.prototype.parse = function(query) {
  this.parser.yy.logDebugTokens = function() {
    console.log.apply(this, arguments);
  };
  this.parser.yy.logDebugGrammar = function() {
    console.log.apply(this, arguments);
  };

  this.parser.yy.pStmt = new ast.SelectStatement();
  this.parser.yy.pStack = [];

  if (!this.parser.parse(query)) {
    return null;
  }

  return this.parser.yy.pStmt;
};

module.exports = N1qlParser;
