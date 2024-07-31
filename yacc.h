#ifndef PARSER_H
#define PARSER_H

enum {
    IF = 258,
    IDENTIFIER,
    NUMBER,
    NOT_EQUAL,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    BREAK,
    SEMICOLON
};

// 関数プロトタイプ
int yylex(void);
void yyerror(const char *s);

#endif
