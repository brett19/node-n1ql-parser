/*
Derived From:
https://github.com/couchbaselabs/tuqtng/blob/e490c376be9971daa7524b034156ab64ed8889ee/parser/goyacc/n1ql.nex
*/

%%

\"((\\\")|(\\\\)|(\\\/)|(\\b)|(\\f)|(\\n)|(\\r)|(\\t)|(\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])|[^\"])*\" {
                    yytext = yytext.substr(1,yyleng-2);
                    yy.logDebugTokens("STRING - %s", yytext);
                    return 'STRING';
                  }

\'((\\\")|(\\\\)|(\\\/)|(\\b)|(\\f)|(\\n)|(\\r)|(\\t)|(\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])|[^''])*\'     {
                    yytext = yytext.substr(1,yyleng-2);
                    yy.logDebugTokens("STRING - %s", yytext);
                    return 'STRING';
                  }

\.              { yy.logDebugTokens("DOT"); return 'DOT'; }
\+              { yy.logDebugTokens("PLUS"); return 'PLUS'; }
\-               { yy.logDebugTokens("MINUS"); return 'MINUS'; }
\*              { yy.logDebugTokens("MULT"); return 'MULT'; }
\/              { yy.logDebugTokens("DIV"); return 'DIV'; }
\%               { yy.logDebugTokens("MOD"); return 'MOD'; }
[aA][nN][dD]    { yy.logDebugTokens("AND"); return 'AND'; }
[oO][rR]        { yy.logDebugTokens("OR"); return 'OR'; }
\=\=            { yy.logDebugTokens("EQ"); return 'EQ'; }
\=              { yy.logDebugTokens("EQ"); return 'EQ'; }
\!\=            { yy.logDebugTokens("NE"); return 'NE'; }
\<\>            { yy.logDebugTokens("NE"); return 'NE'; }
\<              { yy.logDebugTokens("LT"); return 'LT'; }
\<\=            { yy.logDebugTokens("LTE"); return 'LTE'; }
\>              { yy.logDebugTokens("GT"); return 'GT'; }
\>\=            { yy.logDebugTokens("GTE"); return 'GTE'; }
[nN][oO][tT]    { yy.logDebugTokens("NOT"); return 'NOT'; }
[lL][iI][kK][eE] { yy.logDebugTokens("LIKE"); return 'LIKE'; }
[iI][sS]        { yy.logDebugTokens("IS"); return 'IS'; }
[mM][iI][sS][sS][iI][nN][gG]
                  { yy.logDebugTokens("MISSING"); return 'MISSING'; }
[vV][aA][lL][uU][eE][dD]
                  { yy.logDebugTokens("VALUED"); return 'VALUED'; }
[sS][eE][lL][eE][cC][tT]
                  { yy.logDebugTokens("SELECT"); return 'SELECT'; }
[aA][sS]        { yy.logDebugTokens("AS"); return 'AS'; }
[iI][nN]        { yy.logDebugTokens("IN"); return 'IN'; }
[fF][rR][oO][mM]
                  { yy.logDebugTokens("FROM"); return 'FROM'; }
[wW][hH][eE][rR][eE]
                  { yy.logDebugTokens("WHERE"); return 'WHERE'; }
[oO][rR][dD][eE][rR]
                  { yy.logDebugTokens("ORDER"); return 'ORDER'; }
[bB][yY]        { yy.logDebugTokens("BY"); return 'BY'; }
[aA][sS][cC]    { yy.logDebugTokens("ASC"); return 'ASC'; }
[dD][eE][sS][cC]
                  { yy.logDebugTokens("DESC"); return 'DESC'; }
[lL][iI][mM][iI][tT]
                  { yy.logDebugTokens("LIMIT"); return 'LIMIT'; }
[oO][fF][fF][sS][eE][tT]
                  { yy.logDebugTokens("OFFSET"); return 'OFFSET'; }
[eE][xX][pP][lL][aA][iI][nN]
                  {
                    yy.logDebugTokens("EXPLAIN"); return 'EXPLAIN';
                  }
[dD][iI][sS][tT][iI][nN][cC][tT]
                  {
                    yy.logDebugTokens("DISTINCT"); return 'DISTINCT';
                  }
[uU][nN][iI][qQ][uU][eE]
                  {
                    yy.logDebugTokens("UNIQUE"); return 'UNIQUE';
                  }
[cC][aA][sS][eE]
                  {
                    yy.logDebugTokens("CASE"); return 'CASE';
                  }
[wW][hH][eE][nN]
                  {
                    yy.logDebugTokens("WHEN"); return 'WHEN';
                  }
[tT][hH][eE][nN]
                  {
                    yy.logDebugTokens("THEN"); return 'THEN';
                  }
[eE][lL][sS][eE]
                  {
                    yy.logDebugTokens("ELSE"); return 'ELSE';
                  }
[eE][nN][dD]
                  {
                    yy.logDebugTokens("END"); return 'END';
                  }
[aA][nN][yY]    {
                    yy.logDebugTokens("ANY"); return 'ANY';
                  }
[fF][iI][rR][sS][tT]
                  {
                    yy.logDebugTokens("FIRST"); return 'FIRST';
                  }
[aA][lL][lL]    {
                    yy.logDebugTokens("ALL"); return 'ALL';
                  }
[gG][rR][oO][uU][pP]
                  {
                    yy.logDebugTokens("GROUP"); return 'GROUP';
                  }
[bB][yY]        {
                    yy.logDebugTokens("BY"); return 'BY';
                  }
[hH][aA][vV][iI][nN][gG]
                  {
                    yy.logDebugTokens("HAVING"); return 'HAVING';
                  }
[cC][rR][eE][aA][tT][eE]
                  {
                    yy.logDebugTokens("CREATE"); return 'CREATE';
                  }
[dD][rR][oO][pP]
                  {
                    yy.logDebugTokens("DROP"); return 'DROP';
                  }
[vV][iI][eE][wW]
                  {
                    yy.logDebugTokens("VIEW"); return 'VIEW';
                  }
[uU][sS][iI][nN][gG]
                  {
                    yy.logDebugTokens("USING"); return 'USING';
                  }
[iI][nN][dD][eE][xX]
                  {
                    yy.logDebugTokens("INDEX"); return 'INDEX';
                  }
[oO][nN]
                  {
                    yy.logDebugTokens("ON"); return 'ON';
                  }
[pP][rR][iI][mM][aA][rR][yY]
                  {
                    yy.logDebugTokens("PRIMARY"); return 'PRIMARY';
                  }
[aA][rR][rR][aA][yY]
                  {
                    yy.logDebugTokens("ARRAY"); return 'ARRAY';
                  }
[aA][lL][tT][eE][rR]
                  {
                    yy.logDebugTokens("ALTER"); return 'ALTER';
                  }
[bB][eE][tT][wW][eE][eE][nN]
                  {
                    yy.logDebugTokens("BETWEEN"); return 'BETWEEN';
                  }
[bB][uU][cC][kK][eE][tT]
                  {
                    yy.logDebugTokens("BUCKET"); return 'BUCKET';
                  }
[cC][aA][sS][tT]
                  {
                    yy.logDebugTokens("CAST"); return 'CAST';
                  }
[cC][oO][lL][lL][aA][tT][eE]
                  {
                    yy.logDebugTokens("COLLATE"); return 'COLLATE';
                  }
[dD][aA][tT][aA][bB][aA][sS][eE]
                  {
                    yy.logDebugTokens("DATABASE"); return 'DATABASE';
                  }
[dD][eE][lL][eE][tT][eE]
                  {
                    yy.logDebugTokens("DELETE"); return 'DELETE';
                  }
[eE][aA][cC][hH]
                  {
                    yy.logDebugTokens("EACH"); return 'EACH';
                  }
[eE][xX][cC][eE][pP][tT]
                  {
                    yy.logDebugTokens("EXCEPT"); return 'EXCEPT';
                  }
[eE][xX][iI][sS][tT][sS]
                  {
                    yy.logDebugTokens("EXISTS"); return 'EXISTS';
                  }
[iI][fF]        { yy.logDebugTokens("IF"); return 'IF'; }
[iI][nN][lL][iI][nN][eE]
                  {
                    yy.logDebugTokens("INLINE"); return 'INLINE';
                  }
[iI][nN][sS][eE][rR][tT]
                  {
                    yy.logDebugTokens("INSERT"); return 'INSERT';
                  }
[iI][nN][tT][eE][rR][sS][eE][cC][tT]
                  {
                    yy.logDebugTokens("INTERSECT"); return 'INTERSECT';
                  }
[iI][nN][tT][oO]
                  {
                    yy.logDebugTokens("INTO"); return 'INTO';
                  }
[jJ][oO][iI][nN]
                  {
                    yy.logDebugTokens("JOIN"); return 'JOIN';
                  }
[pP][aA][tT][hH]
                  {
                    yy.logDebugTokens("PATH"); return 'PATH';
                  }
[uU][nN][iI][oO][nN]
                  {
                    yy.logDebugTokens("UNION"); return 'UNION';
                  }
[uU][pP][dD][aA][tT][eE]
                  {
                    yy.logDebugTokens("UPDATE"); return 'UPDATE';
                  }
[pP][oO][oO][lL]
                  {
                    yy.logDebugTokens("POOL"); return 'POOL';
                  }
[sS][aA][tT][iI][sS][fF][iI][eE][sS]
                  {
                    yy.logDebugTokens("SATISFIES"); return 'SATISFIES';
                  }
[eE][vV][eE][rR][yY]
                  {
                    yy.logDebugTokens("EVERY"); return 'EVERY';
                  }
[uU][nN][nN][eE][sS][tT]
                  {
                    yy.logDebugTokens("UNNEST"); return 'UNNEST';
                  }
[fF][oO][rR]
                  {
                    yy.logDebugTokens("FOR"); return 'FOR';
                  }
[kK][eE][yY]
                  {
                    yy.logDebugTokens("KEY"); return 'KEY';
                  }
[kK][eE][yY][sS]
                  {
                    yy.logDebugTokens("KEYS"); return 'KEYS';
                  }
[iI][nN][nN][eE][rR]
                  {
                    yy.logDebugTokens("INNER"); return 'INNER';
                  }
[oO][uU][tT][eE][rR]
                  {
                    yy.logDebugTokens("OUTER"); return 'OUTER';
                  }
[lL][eE][fF][tT]
                  {
                    yy.logDebugTokens("LEFT"); return 'LEFT';
                  }
[nN][eE][sS][tT]
                  {
                    yy.logDebugTokens("NEST"); return 'NEST';
                  }
\|\|            { yy.logDebugTokens("CONCAT"); return 'CONCAT'; }
\(              { yy.logDebugTokens("LPAREN"); return 'LPAREN'; }
\)              { yy.logDebugTokens("RPAREN"); return 'RPAREN'; }
\{              { yy.logDebugTokens("LBRACE"); return 'LBRACE'; }
\}              { yy.logDebugTokens("RBRACE"); return 'RBRACE'; }
\,              { yy.logDebugTokens("COMMA"); return 'COMMA'; }
\:              { yy.logDebugTokens("COLON"); return 'COLON'; }
\[              { yy.logDebugTokens("LBRACKET"); return 'LBRACKET'; }
\]              { yy.logDebugTokens("RBRACKET"); return 'RBRACKET'; }
[tT][rR][uU][eE]
                  { yy.logDebugTokens("TRUE"); return 'TRUE';}
[fF][aA][lL][sS][eE]
                  { yy.logDebugTokens("FALSE"); return 'FALSE';}
[nN][uU][lL][lL]
                  { yy.logDebugTokens("NULL"); return 'NULL';}
([0-9]|[1-9][0-9]*)(\.[0-9][0-9]*)([eE][+\-]?[0-9][0-9]*)?
                  {
                  // there are 2 separate rules for NUMBER
                  // instead of 1 with two optional components
                  // to differntiate it from plan INT
                    yy.logDebugTokens("NUMBER - %f", yytext);
                    yytext = parseDouble(yytext);
                    return 'NUMBER';
                  }
([0-9]|[1-9][0-9]*)(\.[0-9][0-9]*)?([eE][+\-]?[0-9][0-9]*)
                  {
                    yy.logDebugTokens("NUMBER - %f", yytext);
                    yytext = parseDouble(yytext);
                    return 'NUMBER';
                  }
[0-9]|[1-9][0-9]*
                  {
                    yy.logDebugTokens("INT - %d", yytext);
                    yytext = parseInt(yytext);
                    return 'INT';
                  }
[ \t\n]+        { yy.logDebugTokens("WHITESPACE (count=%d)", yytext.length); /* eat up whitespace */ }
[a-zA-Z_][a-zA-Z0-9\-_]*     {
                    yy.logDebugTokens("IDENTIFIER - %s", yytext);
                    return 'IDENTIFIER';
                  }
`((\\\")|(\\\\)|(\\\/)|(\\b)|(\\f)|(\\n)|(\\r)|(\\t)|(\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])|[^`])+`
                  {
                    //this rule allows for a wider range of identifiers by escaping them
                    yytext = yytext.substr(1,yyleng-2);
                    yy.logDebugTokens("IDENTIFIER - %s", yytext);
                    return 'IDENTIFIER';
                  }
