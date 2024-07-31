%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "yacc.tab.h"
%}

%option yylineno

%%
"int"       { return INT; }
"return"    { return RETURN; }
"main"      { return MAIN; }
"if"        { return IF; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }
"!="        { return NOT_EQUAL; }
"="         { return ASSIGN; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMICOLON; }
[ \t\n]+    { /* ignore whitespace */ }
.           { printf("Unexpected character: %s\n", yytext); }
%%

int yywrap(void) {
    return 1;
}
