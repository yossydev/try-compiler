CC = cc

parser: lex.yy.c yacc.tab.c
	$(CC) -o $@ $^ -ll

lex.yy.c: lex.l
	lex $<

yacc.tab.c: yacc.y
	bison -d $<

clean:
	rm -fr parser && rm -f lex.yy.c yacc.tab.c
