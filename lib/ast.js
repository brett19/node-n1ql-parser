"use strict";

var util = require('util');

var ast = {};

/*
Shenanigans to make life easier
 */
function newAstArray(Type, args) {
  var newObj = new Type();
  for (var i = 0; i < args.length; ++i) {
    newObj.push(args[i]);
  }
  return newObj;
}

function AstArray() {
}
(function(nType, baseType) {util.inherits(nType, baseType);})(AstArray, Array);

AstArray.prototype.inspect = function(depth) {
  var out = [];
  for (var i = 0; i < this.length; ++i) {
    out.push(util.inspect(this[i], {depth: depth-1}));
  }
  return '[' + out.join(',') + ']';
};

function AstObject(opts) {
  if (opts) {
    for (var i in opts) {
      if (opts.hasOwnProperty(i)) {
        this[i] = opts[i];
      }
    }
  }
}

function astType(baseType, func) {
  var newType = function(opts) {
    this._T = this.__AstType;
    if (opts && !(opts instanceof Object)) {
      throw new Error('Incorrect creation of AstType');
    }
    if (func) {
      func.call(this);
    }
    baseType.call(this, opts);
  };
  util.inherits(newType, baseType);
  return newType;
}

function astObject(func) {
  return astType(AstObject, func);
}
function astArray(func) {
  return astType(AstArray, func);
}


/*
Actual AST stuff
 */

ast.Literal = astObject(function() {
  this.Type = 'unknown';
  this.Value = null;
});
ast.newLiteralNumber = function(value) {
  return new ast.Literal({
    Type: 'number',
    Value: value
  });
};
ast.newLiteralString = function(value) {
  return new ast.Literal({
    Type: 'string',
    Value: value
  });
};
ast.newLiteralBool = function(value) {
  return new ast.Literal({
    Type: 'bool',
    Value: value
  });
};
ast.newLiteralNull = function(value) {
  return new ast.Literal({
    Type: 'null'
  });
};


ast.BinaryOperator = astObject(function() {
  this.Type = 'unknown';
  this.Left = null;
  this.Right = null;
});
function newBinaryOperator(type, left, right) {
  return new ast.BinaryOperator({
    Type: type,
    Left: left,
    Right: right
  });
}

ast.UnaryOperator = astObject(function() {
  this.Type = 'unknown';
  this.Operand = null;
});
function newUnaryOperator(type, operand) {
  return new ast.UnaryOperator({
    Type: type,
    Operand: operand
  });
}

ast.PrefixUnaryOperator = astObject(function() {
  this.Type = 'unknown';
  this.Operand = null;
});
function newPrefixUnaryOperator(type, operand) {
  return new ast.PrefixUnaryOperator({
    Type: type,
    Operand: operand
  });
}

ast.NaryOperator = astObject(function() {
  this.Type = 'unknown';
  this.Operands = null;
});
function newNaryOperator(type, operands) {
  return new ast.NaryOperator({
    Type: type,
    Operands: operands
  });
}

ast.newGreaterThanOperator = function(left, right) {
  return newBinaryOperator('greater_than', left, right);
};
ast.newGreaterThanOrEqualOperator = function(left, right) {
  return newBinaryOperator('greater_than_or_equal', left, right);
};
ast.newLessThanOperator = function(left, right) {
  return newBinaryOperator('less_than', left, right);
};
ast.newLessThanOrEqualOperator = function(left, right) {
  return newBinaryOperator('less_than_or_equal', left, right);
};
ast.newEqualToOperator = function(left, right) {
  return newBinaryOperator('equals', left, right);
};
ast.newNotEqualToOperator = function(left, right) {
  return newBinaryOperator('not_equals', left, right);
};
ast.newLikeOperator = function(left, right) {
  return newBinaryOperator('like', left, right);
};
ast.newNotLikeOperator = function(left, right) {
  return newBinaryOperator('not_like', left, right);
};
ast.newInOperator = function(left, right) {
  return newBinaryOperator('in', left, right);
};
ast.newNotInOperator = function(left, right) {
  return newBinaryOperator('not_in', left, right);
};
ast.newIsNullOperator = function(operand) {
  return newUnaryOperator('is_null', operand);
};
ast.newIsNotNullOperator = function(operand) {
  return newUnaryOperator('is_not_null', operand);
};
ast.newIsMissingOperator = function(operand) {
  return newUnaryOperator('is_missing', operand);
};
ast.newIsNotMissingOperator = function(operand) {
  return newUnaryOperator('is_not_missing', operand);
};
ast.newIsValuedOperator = function(operand) {
  return newUnaryOperator('is_valued', operand);
};
ast.newIsNotValuedOperator = function(operand) {
  return newUnaryOperator('is_not_valued', operand);
};

ast.newPlusOperator = function(left, right) {
  return newBinaryOperator('plus', left, right);
};
ast.newSubtractOperator = function(left, right) {
  return newBinaryOperator('minus', left, right);
};
ast.newMultiplyOperator = function(left, right) {
  return newBinaryOperator('multiply', left, right);
};
ast.newDivideOperator = function(left, right) {
  return newBinaryOperator('divide', left, right);
};
ast.newModuloOperator = function(left, right) {
  return newBinaryOperator('modulo', left, right);
};
ast.newChangeSignOperator = function(left, right) {
  return newPrefixUnaryOperator('changesign', left, right);
};

ast.newAndOperator = function(operands) {
  return newUnaryOperator('and', operands);
};
ast.newOrOperator = function(operands) {
  return newUnaryOperator('or', operands);
};
ast.newNotOperator = function(operand) {
  return newPrefixUnaryOperator('not', operand);
};

ast.ResultExpressionList = astArray();
ast.newResultExpressionList = function() {
  return newAstArray(ast.ResultExpressionList, arguments);
};


ast.SortExpression = astObject(function() {
  this.Expr = null;
  this.Ascending = false;
});
ast.newSortExpression = function(expr, asc) {
  return new ast.SortExpression({
    Expr: expr,
    Ascending: asc
  });
};

ast.SortExpressionList = astArray();


ast.FunctionArgExpression = astObject(function() {
  this.Star = false;
  this.Expr = null;
});
ast.newStarFunctionArgExpression = function() {
  return new ast.FunctionArgExpression({
    Star: true
  });
};
ast.newDotStarFunctionArgExpression = function(expr) {
  return new ast.FunctionArgExpression({
    Star: true,
    Expr: expr
  });
};
ast.newFunctionArgExpression = function(expr) {
  return new ast.FunctionArgExpression({
    Expr: expr
  });
};

ast.FunctionArgExpressionList = astArray();

ast.ExpressionList = astArray();

// TODO: Fix function calling to grab proper metadata
ast.FunctionCall = astObject(function(){
  this.Name = null;
  this.Operands = new ast.FunctionArgExpressionList();
});
ast.newFunctionCall = function(name, operands) {
  return new ast.FunctionCall({
    Name: name,
    Operands: operands
  });
};


ast.SelectStatement = astObject(function() {
  this.Distinct = false;
  this.Select = null;
  this.From = null;
  this.Where = null;
  this.GroupBy = null;
  this.Having = null;
  this.OrderBy = new ast.SortExpressionList();
  this.Limit = 0;
  this.Offset = 0;
  this.ExplainOnly = false;
  this.Keys = null;
  this.explicitProjectionAliases = null;
  this.aggregateReferences = null;
});


ast.From = astObject(function() {
  this.Pool = null;
  this.Bucket = null;
  this.Projection = null;
  this.As = null;
  this.Over = null;
});


ast.ResultExpression = astObject(function() {
  this.Star = false;
  this.Expr = null;
  this.As = null;
});
ast.newResultExpression = function(Expr) {
  return new ast.ResultExpression({
    Expr: Expr
  });
};
ast.newDotStarResultExpression = function(Expr) {
  return new ast.ResultExpression({
    Star: true,
    Expr: Expr
  });
};
ast.newStarResultExpression = function() {
  return new ast.ResultExpression({
    Star: true
  });
};
ast.newResultExpressionWithAlias = function(Expr, As) {
  return new ast.ResultExpression({
    Expr: Expr,
    As: As
  });
};


ast.Property = astObject(function() {
  this.Type = 'unknown';
  this.Path = null;
});
ast.newProperty = function(path) {
  return new ast.Property({
    Type: 'property',
    Path: path
  });
};


ast.DotMemberOperator = astObject(function() {
  this.Type = 'unknown';
  this.Left = null;
  this.Right = null;
});
ast.newDotMemberOperator = function(left, right) {
  return new ast.DotMemberOperator({
    Type: 'dot_member',
    Left: left,
    Right: right
  });
};

ast.BracketMemberOperator = astObject(function() {
  this.Type = 'unknown';
  this.Left = null;
  this.Right = null;
});
ast.newBracketMemberOperator = function(left, right) {
  return new ast.DotMemberOperator({
    Type: 'bracket_member',
    Left: left,
    Right: right
  });
};


ast.KeyExpression = astObject(function() {
  this.Expr = null;
  this.Type = 'unknown';
  this.Keys = null;
});
ast.newKeyExpression = function(expr, type) {
  return new ast.KeyExpression({
    Expr: expr,
    Type: type
  });
};



/*
Give everything its proper name ... for debugging
 */
for (var i in ast) {
  if (ast.hasOwnProperty(i)) {
    var astObj = ast[i];
    if (!astObj.super_) {
      // Not a type
      continue;
    }
    if (astObj.super_ !== AstObject && astObject.super_ !== AstArray) {
      // Not an AST type
      continue;
    }

    astObj.prototype.__AstType = i;
  }
}

/*
Export and we're done!
 */
module.exports = ast;