%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern int yylineno;
extern char* yytext;

void yyerror(const char* s);
%}

%union {
    int ival;
    char* sval;
}

%token INT RETURN MAIN IF LPAREN RPAREN LBRACE RBRACE SEMICOLON ASSIGN NOT_EQUAL
%token <sval> IDENTIFIER
%token <ival> NUMBER

%start program

%%

program:
    function_definition
    ;

function_definition:
    INT MAIN LPAREN RPAREN compound_statement
    { printf("Valid main function\n"); }
    ;

compound_statement:
    LBRACE statement_list RBRACE
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    declaration_statement
    | if_statement
    | assignment_statement
    | return_statement
    ;

declaration_statement:
    INT IDENTIFIER ASSIGN NUMBER SEMICOLON
    { printf("Variable declaration: %s = %d\n", $2, $4); free($2); }
    ;

if_statement:
    IF LPAREN condition RPAREN compound_statement
    { printf("Valid if statement\n"); }
    ;

condition:
    IDENTIFIER NOT_EQUAL NUMBER
    { printf("Condition: %s != %d\n", $1, $3); free($1); }
    ;

assignment_statement:
    IDENTIFIER ASSIGN NUMBER SEMICOLON
    { printf("Assignment: %s = %d\n", $1, $3); free($1); }
    ;

return_statement:
    RETURN NUMBER SEMICOLON
    { printf("Return statement: %d\n", $2); }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parse error at line %d: %s near token '%s'\n", yylineno, s, yytext);
    exit(1);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        exit(1);
    }

    FILE* input_file = fopen(argv[1], "r");
    if (!input_file) {
        perror("Error opening file");
        exit(1);
    }

    yyin = input_file;
    yyparse();

    fclose(input_file);
    return 0;
}
