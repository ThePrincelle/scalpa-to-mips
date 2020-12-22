all: parser.y lexer.l
	yacc -d -vvv -d parser.y
	lex lexer.l
	gcc y.tab.c lex.yy.c -ll

clean:
	rm -f *.o y.tab.c y.tab.h lex.yy.cc a.out
