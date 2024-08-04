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

#define MAX_SYMBOLS 100
struct symbol {
    char* name;
    int value;
    int is_initialized;
};

struct symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

int add_symbol(char* name);
int find_symbol(char* name);
void set_symbol_value(int index, int value);
%}

%union {
    int ival;
    char* sval;
}

%token INT RETURN MAIN IF LPAREN RPAREN LBRACE RBRACE SEMICOLON ASSIGN NOT_EQUAL
%token <sval> IDENTIFIER
%token <ival> NUMBER

%type <ival> expression

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
    INT IDENTIFIER ASSIGN expression SEMICOLON
    {
        int index = add_symbol($2);
        if (index == -1) {
            yyerror("Variable already declared");
        } else {
            set_symbol_value(index, $4);
            printf("Variable declaration: %s = %d\n", $2, $4);
        }
        free($2);
    }
    ;

if_statement:
    IF LPAREN condition RPAREN compound_statement
    { printf("Valid if statement\n"); }
    ;

condition:
    IDENTIFIER NOT_EQUAL expression
    {
        int index = find_symbol($1);
        if (index == -1) {
            yyerror("Undeclared variable");
        } else {
            printf("Condition: %s != %d\n", $1, $3);
        }
        free($1);
    }
    ;

assignment_statement:
    IDENTIFIER ASSIGN expression SEMICOLON
    {
        int index = find_symbol($1);
        if (index == -1) {
            yyerror("Undeclared variable");
        } else {
            set_symbol_value(index, $3);
            printf("Assignment: %s = %d\n", $1, $3);
        }
        free($1);
    }
    ;

return_statement:
    RETURN expression SEMICOLON
    { printf("Return statement: %d\n", $2); }
    ;

expression:
    NUMBER { $$ = $1; }
    | IDENTIFIER
    {
        int index = find_symbol($1);
        if (index == -1) {
            yyerror("Undeclared variable");
            $$ = 0;
        } else {
            if (!symbol_table[index].is_initialized) {
                yyerror("Use of uninitialized variable");
            }
            $$ = symbol_table[index].value;
        }
        free($1);
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error at line %d: %s near token '%s'\n", yylineno, s, yytext);
    exit(1);
}

int add_symbol(char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return -1; // Symbol already exists
        }
    }
    if (symbol_count >= MAX_SYMBOLS) {
        yyerror("Symbol table full");
        return -1;
    }
    symbol_table[symbol_count].name = strdup(name);
    symbol_table[symbol_count].is_initialized = 0;
    return symbol_count++;
}

int find_symbol(char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1; 
}

void set_symbol_value(int index, int value) {
    symbol_table[index].value = value;
    symbol_table[index].is_initialized = 1;
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
