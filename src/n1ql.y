/*
Derived From:
https://github.com/couchbaselabs/tuqtng/blob/e490c376be9971daa7524b034156ab64ed8889ee/parser/goyacc/n1ql.y
*/

%{{

var ast = require('./ast');

}}%

%token ALTER  BUCKET CAST COLLATE
%token DATABASE DELETE EACH EXCEPT EXISTS
%token IF INLINE INSERT INTERSECT INTO
%token JOIN PATH UNION UPDATE POOL
%token EXPLAIN
%token CREATE DROP PRIMARY VIEW INDEX ON USING
%token DISTINCT UNIQUE
%token SELECT AS FROM WHERE KEY KEYS
%token ORDER BY ASC DESC
%token LIMIT OFFSET
%token GROUP BY HAVING
%token LBRACE RBRACE LBRACKET RBRACKET
%token COMMA COLON
%token TRUE FALSE NULL
%token INT NUMBER IDENTIFIER STRING
%token PLUS MINUS MULT DIV
%token CONCAT
%token AND OR NOT
%token EQ NE GT GTE LT LTE
%token LPAREN RPAREN
%token LIKE IS VALUED MISSING BETWEEN
%token DOT
%token CASE WHEN THEN ELSE END
%token ANY ALL FIRST ARRAY IN SATISFIES EVERY UNNEST FOR
%token JOIN NEST INNER LEFT OUTER
%left OR
%left AND
%left EQ LT LTE GT GTE NE LIKE BETWEEN
%left PLUS MINUS
%left MULT DIV MOD CONCAT
%left IS
%right NOT
%left DOT LBRACKET

%%

input:
stmt {
	yy.logDebugGrammar("INPUT")
}
|
EXPLAIN stmt {
	yy.logDebugGrammar("INPUT - EXPLAIN");
	yy.pStmt.ExplainOnly = true;
}
;

stmt:
select_stmt {
	yy.logDebugGrammar("STMT - SELECT")
}
|
create_index_stmt {
}
|
drop_index_stmt {
	yy.logDebugGrammar("STMT - DROP INDEX")
}
;

// CREATE INDEX STATEMENT
create_index_stmt:
create_primary_index_stmt {
	yy.logDebugGrammar("STMT - CREATE PRIMARY INDEX")
}
|
create_secondary_index_stmt {
	yy.logDebugGrammar("STMT - CREATE SECONDARY INDEX")
}
;

create_primary_index_stmt:
CREATE PRIMARY INDEX ON IDENTIFIER {
/*	bucket := $5.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.Bucket = bucket
	createIndexStmt.Primary = true
	parsingStatement = createIndexStmt */
}
|
CREATE PRIMARY INDEX ON COLON IDENTIFIER DOT IDENTIFIER {
/*	pool := $6.s
	bucket := $8.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.Pool = pool
	createIndexStmt.Bucket = bucket
	createIndexStmt.Primary = true
	parsingStatement = createIndexStmt */
}
|
CREATE PRIMARY INDEX ON IDENTIFIER USING view_using {
/*	method := parsingStack.Pop().(string)
	bucket := $5.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.Bucket = bucket
	createIndexStmt.Method = method
	createIndexStmt.Primary = true
	parsingStatement = createIndexStmt */
}
|
CREATE PRIMARY INDEX ON COLON IDENTIFIER DOT IDENTIFIER USING view_using {
/*	method := parsingStack.Pop().(string)
	bucket := $8.s
	pool := $6.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.Pool = pool
	createIndexStmt.Bucket = bucket
	createIndexStmt.Method = method
	createIndexStmt.Primary = true
	parsingStatement = createIndexStmt */
}
;

create_secondary_index_stmt:
CREATE INDEX IDENTIFIER ON IDENTIFIER LPAREN expression_list RPAREN {
/*	on := parsingStack.Pop().(ast.ExpressionList)
	bucket := $5.s
	name := $3.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.On = on
	createIndexStmt.Bucket = bucket
	createIndexStmt.Name = name
	createIndexStmt.Primary = false
	parsingStatement = createIndexStmt */
}
|
CREATE INDEX IDENTIFIER ON COLON IDENTIFIER DOT IDENTIFIER LPAREN expression_list RPAREN {
/*	on := parsingStack.Pop().(ast.ExpressionList)
	bucket := $8.s
	pool := $6.s
	name := $3.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.On = on
	createIndexStmt.Pool = pool
	createIndexStmt.Bucket = bucket
	createIndexStmt.Name = name
	createIndexStmt.Primary = false
	parsingStatement = createIndexStmt */
}
|
CREATE INDEX IDENTIFIER ON IDENTIFIER LPAREN expression_list RPAREN USING view_using {
/*	method := parsingStack.Pop().(string)
	on := parsingStack.Pop().(ast.ExpressionList)
	bucket := $5.s
	name := $3.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.On = on
	createIndexStmt.Bucket = bucket
	createIndexStmt.Name = name
	createIndexStmt.Method = method
	createIndexStmt.Primary = false
	parsingStatement = createIndexStmt */
}
|
CREATE INDEX IDENTIFIER ON COLON IDENTIFIER DOT IDENTIFIER LPAREN expression_list RPAREN USING view_using {
/*	method := parsingStack.Pop().(string)
	on := parsingStack.Pop().(ast.ExpressionList)
	bucket := $8.s
	pool := $6.s
	name := $3.s
	createIndexStmt := ast.NewCreateIndexStatement()
	createIndexStmt.On = on
	createIndexStmt.Pool = pool
	createIndexStmt.Bucket = bucket
	createIndexStmt.Name = name
	createIndexStmt.Method = method
	createIndexStmt.Primary = false
	parsingStatement = createIndexStmt */
}
;


view_using:
VIEW {
  yy.pStack.push('view');
}
|
IDENTIFIER {
  yy.pStack.push($1);
}
;

// DROP INDEX
drop_index_stmt:
DROP INDEX IDENTIFIER DOT IDENTIFIER {
/*	bucket := $3.s
	name := $5.s
	dropIndexStmt := ast.NewDropIndexStatement()
	dropIndexStmt.Bucket = bucket
	dropIndexStmt.Name = name
	parsingStatement = dropIndexStmt */
}
|
DROP INDEX COLON IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER {
/*	bucket := $6.s
	pool := $4.s
	name := $8.s
	dropIndexStmt := ast.NewDropIndexStatement()
	dropIndexStmt.Pool = pool
	dropIndexStmt.Bucket = bucket
	dropIndexStmt.Name = name
	parsingStatement = dropIndexStmt */
}
;

// SELECT STATEMENT
select_stmt:
select_compound  {
	yy.logDebugGrammar("SELECT_STMT")
}
;

select_compound:
select_core select_order select_limit_offset {
	// future extensibility for comining queries with UNION, etc
	yy.logDebugGrammar("SELECT_COMPOUND")
}
/*
|
select_core select_order select_limit_offset LPAREN select_compound RPAREN {
    yy.logDebugGrammar("SELECT_COMPOUND NESTED")
}
*/
;

select_core:
select_select select_from select_where select_group_having {
	yy.logDebugGrammar("SELECT_CORE")
}
|
select_from_required select_where select_group_having select_select{
	yy.logDebugGrammar("SELECT_CORE")
}
;


select_group_having:
/* empty */ {
}
|
GROUP BY expression_list having {
  var group_by = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.GroupBy = group_by;
  } else {
    yy.logDebugGrammar("This statement does not support GROUP BY");
  }
}
;

having:
/* empty */ {
}
|
HAVING expression {
	yy.logDebugGrammar("SELECT HAVING - EXPR")
	var having_part = yy.pStack.pop();
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Having = having_part;
  } else {
	  yy.logDebugGrammar("This statement does not support HAVING");
	}
}
;

select_select:
select_select_head select_select_qualifier select_select_tail {
	yy.logDebugGrammar("SELECT_SELECT")
}
;

select_select_head:
SELECT {
	yy.logDebugGrammar("SELECT_SELECT_HEAD")
}
;

select_select_qualifier:
/* empty */ {
}
|
ALL {
/* empty */
}
|
DISTINCT {
	yy.logDebugGrammar("SELECT_SELECT_QUALIFIER DISTINCT")
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Distinct = true;
	} else {
	  yy.logDebugGrammar("This statement does not support WHERE");
	}
}
|
UNIQUE {
	yy.logDebugGrammar("SELECT_SELECT_QUALIFIER UNIQUE")
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Distinct = true;
	} else {
	  yy.logDebugGrammar("This statement does not support WHERE");
	}
}
;

select_select_tail:
result_list {
	yy.logDebugGrammar("SELECT SELECT TAIL - EXPR")
	var result_expr_list = yy.pStack.pop();
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Select = result_expr_list;
	} else {
	  yy.logDebugGrammar("This statement does not support WHERE");
	}
}
;

result_list:
result_single {
  var result_expr = yy.pStack.pop();
  yy.pStack.push(ast.newResultExpressionList(result_expr));
}
|
result_single COMMA result_list {
  var result_expr_list = yy.pStack.pop();
  var result_expr = yy.pStack.pop();
  result_expr_list.unshift(result_expr);
  yy.pStack.push(result_expr_list);
};

result_single:
dotted_path_star {
	yy.logDebugGrammar("RESULT STAR")
}
|
expression {
	yy.logDebugGrammar("RESULT EXPR")
	var expr_part = yy.pStack.pop();
	var result_expr = ast.newResultExpression(expr_part);
	yy.pStack.push(result_expr);
}
|
expression AS IDENTIFIER {
	yy.logDebugGrammar("RESULT EXPR AS ID")
	var expr_part = yy.pStack.pop();
	var result_expr = ast.newResultExpressionWithAlias(expr_part, $3);
	yy.pStack.push(result_expr);
}
|
expression IDENTIFIER {
	yy.logDebugGrammar("RESULT EXPR ID")
  var expr_part = yy.pStack.pop();
  var result_expr = ast.newResultExpressionWithAlias(expr_part, $2);
  yy.pStack.push(result_expr);
}
;

dotted_path_star:
MULT {
	yy.logDebugGrammar("STAR")
  var result_expr = ast.newStarResultExpression();
	yy.pStack.push(result_expr);
}
|
expr DOT MULT {
	yy.logDebugGrammar("PATH DOT STAR")
	var expr_part = yy.pStack.pop();
	var result_expr = ast.newDotStarResultExpression(expr_part);
	yy.pStack.push(result_expr);
}
;

select_from:
/* empty */ {
	yy.logDebugGrammar("SELECT FROM - EMPTY")
}
|
FROM data_source_unnest {
	yy.logDebugGrammar("SELECT FROM - DATASOURCE")
	var from = yy.pStack.pop();
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.From = from;
	} else {
	  yy.logDebugGrammar("This statement does not support FROM");
	}
}
|
FROM COLON IDENTIFIER DOT data_source_unnest {
	yy.logDebugGrammar("SELECT FROM - DATASOURCE WITH POOL")
	var from = yy.pStack.pop();
	from.Pool = $3;
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.From = from;
  } else {
    yy.logDebugGrammar("This statement does not support FROM");
  }
}
;

select_from_required:
FROM data_source_unnest {
	yy.logDebugGrammar("SELECT FROM - DATASOURCE ")
	var from = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.From = from;
  } else {
    yy.logDebugGrammar("This statement does not support FROM");
  }
}
|
FROM COLON IDENTIFIER DOT data_source_unnest {
	yy.logDebugGrammar("SELECT FROM - DATASOURCE WITH POOL")
	var from = yy.pStack.pop();
	from.Pool = $3;
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.From = from;
  } else {
    yy.logDebugGrammar("This statement does not support FROM");
  }
}
;

data_source_unnest:
data_source {
	yy.logDebugGrammar("FROM DATASOURCE WITHOUT UNNEST")
}
|
data_source unnest_source {
	yy.logDebugGrammar("FROM DATASOURCE WITH UNNEST")
	var rest = yy.pStack.pop();
	var last = yy.pStack.pop();
	last.Over = rest;
	yy.pStack.push(last);
}
;

/*unnest_source:*/
unnest_source:
UNNEST path {
    yy.logDebugGrammar("UNNEST")
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Project: proj, As:''}));
}
|
/* unnest subpath AS alias */
UNNEST path AS IDENTIFIER {
    yy.logDebugGrammar("UNNEST AS")
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As:$4}));
}
|
/* unnest subpath AS alias */
UNNEST path IDENTIFIER {
    yy.logDebugGrammar("UNNEST AS")
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As:$3}));
}
|
/* nested unnest */
UNNEST path unnest_source {
    yy.logDebugGrammar("UNNEST nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Over: rest}));
}
|
UNNEST path AS IDENTIFIER unnest_source {
    yy.logDebugGrammar("UNNEST AS nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Over: rest}));
}
|
UNNEST path IDENTIFIER unnest_source {
    yy.logDebugGrammar("UNNEST AS nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $3, Over: rest}));
}
|
join_type UNNEST path {
    yy.logDebugGrammar("UNNEST")
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Type: Type}));
}
|
/* unnest subpath AS alias */
join_type UNNEST path AS IDENTIFIER {
    yy.logDebugGrammar("UNNEST AS")
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Type: Type, As: $5}));
}
|
/* unnest subpath AS alias */
join_type UNNEST path IDENTIFIER {
    yy.logDebugGrammar("UNNEST AS")
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Type: Type, As: $4}));
}
|
/* nested unnest */
join_type UNNEST path unnest_source {
    yy.logDebugGrammar("UNNEST nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Type: Type, As: '', Over: rest}));
}
|
join_type UNNEST path AS IDENTIFIER unnest_source {
    yy.logDebugGrammar("UNNEST AS nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Type: Type, As: $5, Over: rest}));
}
|
join_type UNNEST path IDENTIFIER unnest_source {
    yy.logDebugGrammar("UNNEST AS nested")
    var rest = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Type: Type, As: $4, Over: rest}));
}
|
join_type UNNEST path key_expr {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Type: Type, Keys: key_expr}));
}
|
join_type UNNEST path IDENTIFIER key_expr {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Type: Type, Keys: key_expr}));
}
|
join_type UNNEST path AS IDENTIFIER key_expr {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Type: Type, Keys: key_expr}));
}
|
join_type UNNEST path key_expr unnest_source {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type UNNEST path IDENTIFIER key_expr unnest_source {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type UNNEST path AS IDENTIFIER key_expr unnest_source {
    yy.logDebugGrammar("UNNEST KEY_EXPR")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Type: Type, Keys: key_expr, Over: rest}));
}
|
JOIN path join_key_expr {
    yy.logDebugGrammar("JOIN KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Keys: key_expr}));
}
|
JOIN path AS IDENTIFIER join_key_expr  {
    yy.logDebugGrammar("JOIN AS KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Keys: key_expr}));
}
|
JOIN path IDENTIFIER join_key_expr  {
    yy.logDebugGrammar("JOIN AS KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $3, Keys: key_expr}));
}
|
JOIN path join_key_expr unnest_source {
    yy.logDebugGrammar("JOIN KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Keys: key_expr, Over: rest}));
}
|
JOIN path AS IDENTIFIER join_key_expr unnest_source  {
    yy.logDebugGrammar("JOIN AS KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Keys: key_expr, Over: rest}));
}
|
JOIN path IDENTIFIER join_key_expr unnest_source  {
    yy.logDebugGrammar("JOIN AS KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $3, Keys: key_expr, Over: rest}));
}
|
join_type JOIN path join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Type: Type, Keys: key_expr}));

}
|
join_type JOIN path join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type JOIN path IDENTIFIER join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY IDENTIFIER")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Type: Type, Keys: key_expr}));

}
|
join_type JOIN path IDENTIFIER join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY IDENTIFIER NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type JOIN path AS IDENTIFIER join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY AS IDENTIFIER")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Type: Type, Keys: key_expr}));
}
|
join_type JOIN path AS IDENTIFIER join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY AS IDENTIFIER NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Type: Type, Keys: key_expr, Over: rest}));
}
|
NEST path join_key_expr {
    yy.logDebugGrammar("JOIN KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: '', Keys: key_expr}));
}
|
NEST path AS IDENTIFIER join_key_expr  {
    yy.logDebugGrammar("JOIN AS KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: $4, Keys: key_expr}));
}
|
NEST path IDENTIFIER join_key_expr  {
    yy.logDebugGrammar("JOIN AS KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: $3, Keys: key_expr}));
}
|
NEST path join_key_expr unnest_source {
    yy.logDebugGrammar("JOIN KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: '', Keys: key_expr, Over: rest}));
}
|
NEST path AS IDENTIFIER join_key_expr unnest_source  {
    yy.logDebugGrammar("JOIN AS KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: $4, Keys: key_expr, Over: rest}));
}
|
NEST path IDENTIFIER join_key_expr unnest_source  {
    yy.logDebugGrammar("JOIN AS KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: $3, Keys: key_expr, Over: rest}));
}
|
join_type NEST path join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, Oper: 'NEST', As: '', Type: Type, Keys: key_expr}));

}
|
join_type NEST path join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: '', Oper: 'NEST', Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type NEST path IDENTIFIER join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY IDENTIFIER")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Oper: 'NEST', Type: Type, Keys: key_expr}));

}
|
join_type NEST path IDENTIFIER join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY IDENTIFIER NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $4, Oper: 'NEST', Type: Type, Keys: key_expr, Over: rest}));
}
|
join_type NEST path AS IDENTIFIER join_key_expr {
    yy.logDebugGrammar("TYPE JOIN KEY AS IDENTIFIER")
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Oper: 'NEST', Type: Type, Keys: key_expr}));
}
|
join_type NEST path AS IDENTIFIER join_key_expr unnest_source {
    yy.logDebugGrammar("TYPE JOIN KEY AS IDENTIFIER NESTED")
    var rest = yy.pStack.pop();
    var key_expr = yy.pStack.pop();
    var proj = yy.pStack.pop();
    var Type = yy.pStack.pop();
    yy.pStack.push(new ast.From({Projection: proj, As: $5, Oper: 'NEST', Type: Type, Keys: key_expr, Over: rest}));
}
;

join_key_expr:
KEY expr {
        yy.logDebugGrammar("FROM JOIN DATASOURCE with KEY")
        var key = yy.pStack.pop();
        var key_expr = ast.newKeyExpression(key, 'KEY');
        yy.pStack.push(key_expr);
}
|
KEYS expr {
        yy.logDebugGrammar("FROM DATASOURCE with KEYS")
        var keys = yy.pStack.pop();
        var key_expr = ast.newKeyExpression(keys, 'KEYS');
        yy.pStack.push(key_expr);

};

join_type:
INNER {
    yy.logDebugGrammar("INNER")
    yy.pStack.push('INNER');
}
|
LEFT {
    yy.logDebugGrammar("OUTER")
    yy.pStack.push('LEFT');
}
|
LEFT OUTER {
    yy.logDebugGrammar("LEFT OUTER")
    yy.pStack.push('LEFT');
};


data_source:
path {
	yy.logDebugGrammar("FROM DATASOURCE")
	var proj = yy.pStack.pop();
	yy.pStack.push(new ast.From({Projection: proj}));
}
|
path key_expr {
    yy.logDebugGrammar("FROM KEY(S) DATASOURCE")
	  var proj = yy.pStack.pop();
	  yy.pStack.push(new ast.From({Projection: proj}));
}
|
path AS IDENTIFIER {
    // fixme support over as
	yy.logDebugGrammar("FROM DATASOURCE AS ID")
	var proj = yy.pStack.pop();
	yy.pStack.push(new ast.From({Projection: proj, As: $3}));
}
|
path IDENTIFIER {
    // fixme support over as
	yy.logDebugGrammar("FROM DATASOURCE ID")
	var proj = yy.pStack.pop();
	yy.pStack.push(new ast.From({Projection: proj, As: $2}));
}
|
path AS IDENTIFIER key_expr {
        yy.logDebugGrammar("FROM DATASOURCE AS ID KEY(S)")
	var proj = yy.pStack.pop();
	yy.pStack.push(new ast.From({Projection: proj, As: $3}));

}
|
path IDENTIFIER key_expr {
        yy.logDebugGrammar("FROM DATASOURCE ID KEY(s)")
	var proj = yy.pStack.pop();
	yy.pStack.push(new ast.From({Projection: proj, As: $2}));

}
;

key_expr:
KEY expr {
        yy.logDebugGrammar("FROM DATASOURCE with KEY")
  var keys = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.Keys = ast.newKeyExpression(keys, 'KEY');
  } else {
    yy.logDebugGrammar("This statement does not support KEY");
  }
}
|
KEYS expr {
        yy.logDebugGrammar("FROM DATASOURCE with KEYS")
  var keys = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.Keys = ast.newKeyExpression(keys, 'KEYS');
  } else {
    yy.logDebugGrammar("This statement does not support KEYS");
  }
}
;


select_where:
/* empty */ {
	yy.logDebugGrammar("SELECT WHERE - EMPTY")
}
|
WHERE expression {
	yy.logDebugGrammar("SELECT WHERE - EXPR")
	var where_part = yy.pStack.pop();
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Where = where_part;
	} else {
	  yy.logDebugGrammar("This statement does not support WHERE");
	}
};

select_order:
/* empty */
|
ORDER BY sorting_list {

}
;

sorting_list:
sorting_single {

}
|
sorting_single COMMA sorting_list {

};

sorting_single:
expression {
	yy.logDebugGrammar("SORT EXPR")
  var expr = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.OrderBy.push(ast.newSortExpression(expr, true));
  } else {
    yy.logDebugGrammar("This statement does not support ORDER BY");
  }
}
|
expression ASC {
	yy.logDebugGrammar("SORT EXPR ASC")
  var expr = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.OrderBy.push(ast.newSortExpression(expr, true));
  } else {
    yy.logDebugGrammar("This statement does not support ORDER BY");
  }
}
|
expression DESC {
	yy.logDebugGrammar("SORT EXPR DESC")
  var expr = yy.pStack.pop();
  if (yy.pStmt instanceof ast.SelectStatement) {
    yy.pStmt.OrderBy.push(ast.newSortExpression(expr, false));
  } else {
    yy.logDebugGrammar("This statement does not support ORDER BY");
  }
};

select_limit_offset:
/* empty */ {

}
|
select_limit {

}
|
select_limit select_offset {

}
;

select_limit:
LIMIT INT {
	yy.logDebugGrammar("LIMIT %d", $2);
	if ($2 < 0) {
	  throw new Error('LIMIT cannot be negative');
	}
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Limit = $2;
	} else {
	  yy.logDebugGrammar("This statement does not support LIMIT");
	}
};

select_offset:
OFFSET INT {
	yy.logDebugGrammar("OFFSET %d", $2)
	if ($2 < 0) {
	  throw new Error('OFFSET cannot be negative');
	}
	if (yy.pStmt instanceof ast.SelectStatement) {
	  yy.pStmt.Offset = $2;
	} else {
	  yy.logDebugGrammar("This statement does not support OFFSET");
	}
};

//EXPRESSION


expression:
expr {
	yy.logDebugGrammar("EXPRESSION")
}
|
expr BETWEEN expr AND expr {
    yy.logDebugGrammar(" BETWEEN EXPRESSION")
    var high = yy.pStack.pop();
    var low = yy.pStack.pop();
    var element = yy.pStack.pop();
    var leftExpression = ast.newGreaterThanOrEqualOperator(element, low);
    var rightExpression = ast.newLessThanOrEqualOperator(element, high);
    var thisExpression = ast.newAndOperator(new ast.ExpressionList(leftExpression, rightExpression));
    yy.pStack.push(thisExpression);
}
|
expr NOT BETWEEN expr AND expr {
    yy.logDebugGrammar(" BETWEEN EXPRESSION")
    var high = yy.pStack.pop();
    var low = yy.pStack.pop();
    var element = yy.pStack.pop();
    var leftExpression = ast.newLessThanOperator(element, low);
    var rightExpression = ast.newGreaterThanOperator(element, high);
    var thisExpression = ast.newOrOperator(new ast.ExpressionList(leftExpression, rightExpression));
    yy.pStack.push(thisExpression);
}
|
expr IN expression {
    yy.logDebugGrammar(" IN expression ")
    var right = yy.pStack.pop();
    var left = yy.pStack.pop();
    var thisExpression = ast.newInOperator(left, right);
    yy.pStack.push(thisExpression);
}
|
expr NOT IN expression {
    yy.logDebugGrammar(" IN expression ")
    var right = yy.pStack.pop();
    var left = yy.pStack.pop();
    var thisExpression = ast.newNotInOperator(left, right);
    yy.pStack.push(thisExpression);
}
|
subquery_expr {
};

subquery_expr:
LBRACE select_stmt RBRACE {
    yy.logDebugGrammar("sub-query EXPRESSION")

}
|
LBRACE select_stmt RBRACE subquery_expr {
    yy.logDebugGrammar("sub-query NESTED EXPRESSION")
}
;

expr:
expr PLUS expr {
	yy.logDebugGrammar("EXPR - PLUS")
  var right = yy.pStack.pop();
  var left = yy.pStack.pop();
  var thisExpression = ast.newPlusOperator(left, right);
  yy.pStack.push(thisExpression);
}
|
expr MINUS expr {
	yy.logDebugGrammar("EXPR - MINUS")
  var right = yy.pStack.pop();
  var left = yy.pStack.pop();
  var thisExpression = ast.newSubtractOperator(left, right);
  yy.pStack.push(thisExpression);
}
|
expr MULT expr {
	yy.logDebugGrammar("EXPR - MULT")
  var right = yy.pStack.pop();
  var left = yy.pStack.pop();
  var thisExpression = ast.newMultiplyOperator(left, right);
  yy.pStack.push(thisExpression);
}
|
expr DIV expr {
	yy.logDebugGrammar("EXPR - DIV")
  var right = yy.pStack.pop();
  var left = yy.pStack.pop();
  var thisExpression = ast.newDivideOperator(left, right);
  yy.pStack.push(thisExpression);
}
|
expr MOD expr {
	yy.logDebugGrammar("EXPR - MOD")
  var right = yy.pStack.pop();
  var left = yy.pStack.pop();
  var thisExpression = ast.newModuloOperator(left, right);
  yy.pStack.push(thisExpression);
}
|
expr CONCAT expr {
	yy.logDebugGrammar("EXPR - CONCAT")
	// TODO: Implement This!
	/*right := parsingStack.Pop()
	left := parsingStack.Pop()
	thisExpression := ast.NewStringConcatenateOperator(left.(ast.Expression), right.(ast.Expression))
	parsingStack.Push(thisExpression)*/
}
|
expr AND expr {
	yy.logDebugGrammar("EXPR - AND")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newAndOperator(new ast.ExpressionList(left, right));
	yy.pStack.push(thisExpression);
}
|
expr OR expr {
	yy.logDebugGrammar("EXPR - OR")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newOrOperator(new ast.ExpressionList(left, right));
	yy.pStack.push(thisExpression);
}
|
expr EQ expr {
	yy.logDebugGrammar("EXPR - EQ")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newEqualToOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr LT expr {
	yy.logDebugGrammar("EXPR - LT")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newLessThanOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr LTE expr {
	yy.logDebugGrammar("EXPR - LTE")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newLessThanOrEqualOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr GT expr {
	yy.logDebugGrammar("EXPR - GT")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newGreaterThanOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr GTE expr {
	yy.logDebugGrammar("EXPR - GTE")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newGreaterThanOrEqualOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr NE expr {
	yy.logDebugGrammar("EXPR - NE")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newNotEqualToOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr LIKE expr {
	yy.logDebugGrammar("EXPR - LIKE")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newLikeOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr NOT LIKE expr {
	yy.logDebugGrammar("EXPR - NOT LIKE")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newNotLikeOperator(left, right);
	yy.pStack.push(thisExpression);

}
|
expr DOT IDENTIFIER {
	yy.logDebugGrammar("EXPR DOT MEMBER")
	var right = ast.newProperty($3);
	var left = yy.pStack.pop();
	var thisExpression = ast.newDotMemberOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr LBRACKET expr RBRACKET {
	yy.logDebugGrammar("EXPR BRACKET MEMBER")
	var right = yy.pStack.pop();
	var left = yy.pStack.pop();
	var thisExpression = ast.newBracketMemberOperator(left, right);
	yy.pStack.push(thisExpression);
}
|
expr LBRACKET INT COLON INT RBRACKET {
    yy.logDebugGrammar("EXPR COLON EXPR SLICE BRACKET MEMBER")
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64($3.n)), ast.NewLiteralNumber(float64($5.n)))
    parsingStack.Push(thisExpression)*/
}
|
expr LBRACKET INT COLON RBRACKET {
    yy.logDebugGrammar("EXPR COLON SLICE BRACKET MEMBER")
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64($3.n)), ast.NewLiteralNumber(float64(0)))
    parsingStack.Push(thisExpression)*/

}
|
expr LBRACKET COLON INT RBRACKET {
    yy.logDebugGrammar("COLON EXPR SLICE BRACKET MEMBER")
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64(0)), ast.NewLiteralNumber(float64($4.n)))
    parsingStack.Push(thisExpression)*/
}
|
expr IS NULL {
	yy.logDebugGrammar("SUFFIX_EXPR IS NULL")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsNullOperator(operand);
	yy.pStack.push(thisExpression);
}
|
expr IS NOT NULL {
	yy.logDebugGrammar("SUFFIX_EXPR IS NOT NULL")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsNotNullOperator(operand);
	yy.pStack.push(thisExpression);
}
|
expr IS MISSING {
	yy.logDebugGrammar("SUFFIX_EXPR IS MISSING")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsMissingOperator(operand);
	yy.pStack.push(thisExpression);
}
|
expr IS NOT MISSING {
	yy.logDebugGrammar("SUFFIX_EXPR IS NOT MISSING")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsNotMissingOperator(operand);
	yy.pStack.push(thisExpression);
}
|
expr IS VALUED {
	yy.logDebugGrammar("SUFFIX_EXPR IS VALUED")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsValuedOperator(operand);
	yy.pStack.push(thisExpression);
}
|
expr IS NOT VALUED {
	yy.logDebugGrammar("SUFFIX_EXPR IS NOT VALUED")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newIsNotValuedOperator(operand);
	yy.pStack.push(thisExpression);
}
|
prefix_expr {

}
;

prefix_expr:
NOT prefix_expr {
	yy.logDebugGrammar("EXPR - NOT")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newNotOperator(operand);
	yy.pStack.push(thisExpression);
}
|
MINUS prefix_expr {
	yy.logDebugGrammar("EXPR - CHANGE SIGN")
	var operand = yy.pStack.pop();
	var thisExpression = ast.newChangeSignOperator(operand);
	yy.pStack.push(thisExpression);
}
|
suffix_expr {

};

suffix_expr:
atom {
	yy.logDebugGrammar("SUFFIX_EXPR")
}
;

atom:
IDENTIFIER {
	yy.logDebugGrammar("IDENTIFIER - %s", $1.s)
	var thisExpression = ast.newProperty($1);
	yy.pStack.push(thisExpression);
}
|
literal_value {
	yy.logDebugGrammar("LITERAL")
}
|
LPAREN expression RPAREN {
	yy.logDebugGrammar("NESTED EXPR")
}
|
CASE WHEN then_list else_expr END {
	yy.logDebugGrammar("CASE WHEN THEN ELSE END")
	throw new Error('not_yet_supported');
	/*cwtee := ast.NewCaseOperator()
	topStack := parsingStack.Pop()
	switch topStack := topStack.(type) {
	case ast.Expression:
		cwtee.Else = topStack
		// now look for whenthens
		nextStack := parsingStack.Pop().([]*ast.WhenThen)
		cwtee.WhenThens = nextStack
	case []*ast.WhenThen:
		// no else
		cwtee.WhenThens = topStack
	}
	parsingStack.Push(cwtee)*/
}
|
CASE expr WHEN then_list else_expr END {
	yy.logDebugGrammar("CASE WHEN THEN ELSE END")
	throw new Error('not_yet_supported');
	/*cwtee := ast.NewCaseOperator()
	topStack := parsingStack.Pop()
	switch topStack := topStack.(type) {
	case ast.Expression:
		cwtee.Else = topStack
		// now look for whenthens
		nextStack := parsingStack.Pop().([]*ast.WhenThen)
		cwtee.WhenThens = nextStack
	case []*ast.WhenThen:
		// no else
		cwtee.WhenThens = topStack
	}
        cwtee.Switch = parsingStack.Pop().(ast.Expression)
	parsingStack.Push(cwtee)*/
}
|
ANY expr SATISFIES expr END {
    yy.logDebugGrammar("ANY SATISFIES")
    throw new Error('not_yet_supported');
    /*condition := parsingStack.Pop().(ast.Expression)
    sub := parsingStack.Pop().(ast.Expression)
    collectionAny := ast.NewCollectionAnyOperator(condition, sub, "")
    parsingStack.Push(collectionAny)*/
}
|
ANY IDENTIFIER IN expr SATISFIES expr END {
    yy.logDebugGrammar("ANY IN SATISFIES")
    throw new Error('not_yet_supported');
    /*condition := parsingStack.Pop().(ast.Expression)
    sub := parsingStack.Pop().(ast.Expression)
    collectionAny := ast.NewCollectionAnyOperator(condition, sub, $2.s)
    parsingStack.Push(collectionAny)*/
}
|
EVERY IDENTIFIER IN expr SATISFIES expr END {
    yy.logDebugGrammar("ANY IN SATISFIES")
    throw new Error('not_yet_supported');
    /*condition := parsingStack.Pop().(ast.Expression)
    sub := parsingStack.Pop().(ast.Expression)
    collectionAny := ast.NewCollectionAllOperator(condition, sub, $2.s)
    parsingStack.Push(collectionAny)*/
}
|
 EVERY expr SATISFIES expr END {
    yy.logDebugGrammar("ANY SATISFIES")
    throw new Error('not_yet_supported');
    /*condition := parsingStack.Pop().(ast.Expression)
    sub := parsingStack.Pop().(ast.Expression)
    collectionAny := ast.NewCollectionAllOperator(condition, sub, "")
    parsingStack.Push(collectionAny)*/
}
|
FIRST expr FOR IDENTIFIER IN expr WHEN expr END {
	yy.logDebugGrammar("FIRST FOR IN WHEN")
	throw new Error('not_yet_supported');
	/*condition := parsingStack.Pop().(ast.Expression)
	sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionFirst := ast.NewCollectionFirstOperator(condition, sub, $4.s, output)
	parsingStack.Push(collectionFirst)*/
}
|
FIRST expr IN expr WHEN expr END {
	yy.logDebugGrammar("FIRST IN WHEN")
	throw new Error('not_yet_supported');
	/*condition := parsingStack.Pop().(ast.Expression)
	sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionFirst := ast.NewCollectionFirstOperator(condition, sub, "", output)
	parsingStack.Push(collectionFirst)*/
}
|
FIRST expr FOR IDENTIFIER IN expr END {
	yy.logDebugGrammar("FIRST FOR IN")
	throw new Error('not_yet_supported');
	/*sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionFirst := ast.NewCollectionFirstOperator(nil, sub, $4.s, output)
	parsingStack.Push(collectionFirst)*/
}
|
FIRST expr IN expr END {
	yy.logDebugGrammar("FIRST IN")
	throw new Error('not_yet_supported');
	/*sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionFirst := ast.NewCollectionFirstOperator(nil, sub, "", output)
	parsingStack.Push(collectionFirst)*/
}
|
ARRAY expr FOR IDENTIFIER IN expr WHEN expr END {
	yy.logDebugGrammar("ARRAY FOR IN WHEN")
	throw new Error('not_yet_supported');
	/*condition := parsingStack.Pop().(ast.Expression)
	sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionArray := ast.NewCollectionArrayOperator(condition, sub, $4.s, output)
	parsingStack.Push(collectionArray)*/
}
|
ARRAY expr IN expr WHEN expr END {
	yy.logDebugGrammar("ARRAY IN WHEN")
	throw new Error('not_yet_supported');
	/*condition := parsingStack.Pop().(ast.Expression)
	sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionArray := ast.NewCollectionArrayOperator(condition, sub, "", output)
	parsingStack.Push(collectionArray)*/
}
|
ARRAY expr FOR IDENTIFIER IN expr END {
	yy.logDebugGrammar("ARRAY FOR IN")
	throw new Error('not_yet_supported');
	/*sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionArray := ast.NewCollectionArrayOperator(nil, sub, $4.s, output)
	parsingStack.Push(collectionArray)*/
}
|
ARRAY expr IN expr END {
	yy.logDebugGrammar("ARRAY IN")
	throw new Error('not_yet_supported');
	/*sub := parsingStack.Pop().(ast.Expression)
	output := parsingStack.Pop().(ast.Expression)
	collectionArray := ast.NewCollectionArrayOperator(nil, sub, "", output)
	parsingStack.Push(collectionArray)*/
}
|
IDENTIFIER LPAREN RPAREN {
	yy.logDebugGrammar("FUNCTION EXPR NOPARAM")
	var thisExpression = ast.newFunctionCall($1, new ast.FunctionArgExpressionList());
	yy.pStack.push(thisExpression);
}
|
IDENTIFIER LPAREN function_arg_list RPAREN {
	yy.logDebugGrammar("FUNCTION EXPR PARAM")
	var funarg_exp_list = yy.pStack.pop();
	var thisExpression = ast.newFunctionCall($1, funarg_exp_list);
	yy.pStack.push(thisExpression);
}
|
IDENTIFIER LPAREN DISTINCT function_arg_list RPAREN {
	yy.logDebugGrammar("FUNCTION DISTINCT EXPR PARAM")
	var funarg_exp_list = yy.pStack.pop();
	var thisFunction = ast.newFunctionCall($1, funarg_exp_list);
	thisFunction.Distinct = true;
	yy.pStack.push(thisFunction);
}
|
IDENTIFIER LPAREN UNIQUE function_arg_list RPAREN {
	yy.logDebugGrammar("FUNCTION EXPR PARAM")
	var funarg_exp_list = yy.pStack.pop();
	var thisExpression = ast.newFunctionCall($1, funarg_exp_list);
	yy.pStack.push(thisExpression);
}
;

then_list:
expr THEN expr {
	yy.logDebugGrammar("THEN_LIST - SINGLE")
	throw new Error('not_yet_supported');
	/*when_then_list := make([]*ast.WhenThen, 0)
	when_then := ast.WhenThen{Then: parsingStack.Pop().(ast.Expression), When: parsingStack.Pop().(ast.Expression)}
	when_then_list = append(when_then_list, &when_then)
	parsingStack.Push(when_then_list)*/
}
|
expr THEN expr WHEN then_list {
	yy.logDebugGrammar("THEN_LIST - COMPOUND")
	throw new Error('not_yet_supported');
	/*rest := parsingStack.Pop().([]*ast.WhenThen)
	last := ast.WhenThen{Then: parsingStack.Pop().(ast.Expression), When: parsingStack.Pop().(ast.Expression)}
	new_list := make([]*ast.WhenThen, 0, len(rest) + 1)
	new_list = append(new_list, &last)
	for _, v := range rest {
		new_list = append(new_list, v)
	}
	parsingStack.Push(new_list)*/
}
;

else_expr:
/* empty */ {
	yy.logDebugGrammar("ELSE - EMPTY")
}
|
ELSE expr {
	yy.logDebugGrammar("ELSE - EXPR")
}
;

path:
IDENTIFIER {
	yy.logDebugGrammar("PATH - %v", $1)
	var thisExpression = ast.newProperty($1);
	yy.pStack.push(thisExpression);
}
|
path LBRACKET INT RBRACKET {
	yy.logDebugGrammar("PATH BRACKET - %v[%v]", $1, $3)
	var left = yy.pStack.pop();
	var thisExpression = ast.newBracketMemberOperator(left, ast.newLiteralNumber($3));
	yy.pStack.push(thisExpression);
}
|
path LBRACKET INT COLON INT RBRACKET {
    yy.logDebugGrammar("PATH SLICE BRACKET MEMBER - %v[%v-%v]", $1,$3, $5)
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64($3.n)), ast.NewLiteralNumber(float64($5.n)))
    parsingStack.Push(thisExpression)*/
}
|
path LBRACKET INT COLON RBRACKET {
    yy.logDebugGrammar("PATH SLICE BRACKET MEMBER - %v[%v:]", $1, $3)
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64($3.n)), ast.NewLiteralNumber(float64(0)))
    parsingStack.Push(thisExpression)*/

}
|
path LBRACKET COLON INT RBRACKET {
    yy.logDebugGrammar("PATH SLICE BRACKET MEMBER -%v[:%v]", $1, $4)
    throw new Error('not_yet_supported');
    /*left := parsingStack.Pop()
    thisExpression := ast.NewBracketSliceMemberOperator(left.(ast.Expression), ast.NewLiteralNumber(float64(0)), ast.NewLiteralNumber(float64($4.n)))
    parsingStack.Push(thisExpression)*/
}
|
path DOT IDENTIFIER {
	yy.logDebugGrammar("PATH DOT PATH - $1")
	var right = ast.newProperty($3);
	var left = yy.pStack.pop();
	var thisExpression = ast.newDotMemberOperator(left, right);
	yy.pStack.push(thisExpression);
}
;


function_arg_list:
function_arg_single {
  var funarg_expr = yy.pStack.pop();
  yy.pStack.push(new ast.FunctionArgExpressionList(funarg_expr));
}
|
function_arg_single COMMA function_arg_list {
  var funarg_expr_list = yy.pStack.pop();
  var funarg_expr = yy.pStack.pop();
  funarg_expr_list.unshift(funarg_expr);
  yy.pStack.push(funarg_expr_list);
}
;

function_arg_single:
fun_dotted_path_star {
	yy.logDebugGrammar("FUNARG STAR")
}
|
expression {
	yy.logDebugGrammar("FUNARG EXPR")
	var expr_part = yy.pStack.pop();
	var funarg_expr = ast.newFunctionArgExpression(expr_part);
	yy.pStack.push(funarg_expr);
}
;

fun_dotted_path_star:
MULT {
	yy.logDebugGrammar("FUNSTAR")
	var funarg_expr = ast.newStarFunctionArgExpression();
	yy.pStack.push(funarg_expr);
}
|
expr DOT MULT {
	yy.logDebugGrammar("FUN PATH DOT STAR")
	var expr_part = yy.pStack.pop();
	var funarg_expr = ast.newDotStarFunctionArgExpression(expr_part);
	yy.pStack.push(funarg_expr);
}
;

//JSON

literal_value:
STRING {
	yy.logDebugGrammar("STRING %s", $1);
	var thisExpression = ast.newLiteralString($1);
	yy.pStack.push(thisExpression);
}
|
number {
	yy.logDebugGrammar("NUMBER")
}
|
object {
	yy.logDebugGrammar("OBJECT")
}
|
array {
	yy.logDebugGrammar("ARRAY")
}
|
TRUE {
	yy.logDebugGrammar("TRUE")
	var thisExpression = ast.newLiteralBool(true);
	yy.pStack.push(thisExpression);
}
|
FALSE {
	yy.logDebugGrammar("FALSE")
	var thisExpression = ast.newLiteralBool(false);
	yy.pStack.push(thisExpression);
}
|
NULL {
	yy.logDebugGrammar("NULL")
	var thisExpression = ast.newLiteralNull();
	yy.pStack.push(thisExpression);
}
;

number:
INT {
	yy.logDebugGrammar("NUMBER %d", $1)
	var thisExpression = ast.newLiteralNumber($1);
	yy.pStack.push(thisExpression);
}
|
NUMBER {
	yy.logDebugGrammar("NUMBER %f", $1)
	var thisExpression = ast.newLiteralNumber($1);
	yy.pStack.push(thisExpression);
}
;

object:
LBRACE RBRACE {
	yy.logDebugGrammar("EMPTY OBJECT")
	throw new Error('not_yet_supported');
	/*emptyObject := ast.NewLiteralObject(map[string]ast.Expression{})
	parsingStack.Push(emptyObject)*/
}
|
LBRACE named_expression_list RBRACE {
	yy.logDebugGrammar("OBJECT")
}
;

named_expression_list:
named_expression_single {
	yy.logDebugGrammar("NAMED EXPR LIST SINGLE")
}
|
named_expression_single COMMA named_expression_list {
	yy.logDebugGrammar("NAMED EXPR LIST COMPOUND")
	throw new Error('not_yet_supported');
	/*last := parsingStack.Pop().(*ast.LiteralObject)
	rest := parsingStack.Pop().(*ast.LiteralObject)
	for k,v := range last.Val {
		rest.Val[k] = v
	}
	parsingStack.Push(rest)*/
}
;

named_expression_single:
STRING COLON expression {
	yy.logDebugGrammar("NAMED EXPR SINGLE")
	throw new Error('not_yet_supported');
	/*thisKey := $1.s
	thisValue := parsingStack.Pop().(ast.Expression)
	thisExpression := ast.NewLiteralObject(map[string]ast.Expression{thisKey: thisValue})
	parsingStack.Push(thisExpression)*/
}
;

array:
LBRACKET RBRACKET {
	yy.logDebugGrammar("EMPTY ARRAY")
	throw new Error('not_yet_supported');
	/*thisExpression := ast.NewLiteralArray(ast.ExpressionList{})
	parsingStack.Push(thisExpression)*/
}
|
LBRACKET expression_list RBRACKET {
	yy.logDebugGrammar("ARRAY")
	throw new Error('not_yet_supported');
	/*exp_list := parsingStack.Pop().(ast.ExpressionList)
	thisExpression := ast.NewLiteralArray(exp_list)
	parsingStack.Push(thisExpression)*/
}
;

expression_list:
expression {
	yy.logDebugGrammar("EXPRESSION LIST SINGLE")
	var exp_list = new ast.ExpressionList();
	exp_list.push(yy.pStack.pop());
	yy.pStack.push(exp_list);
}
|
expression COMMA expression_list {
	yy.logDebugGrammar("EXPRESSION LIST COMPOUND")
	// TODO: This may be incorrectly ordered
	var rest = yy.pStack.pop();
	var last = yy.pStack.pop();
	rest.unshift(last);
	yy.pStack.push(rest);
}
;

%%
