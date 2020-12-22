all: parser.y lexer.l
	yacc -d -v -d parser.y
	lex lexer.l
	gcc y.tab.c lex.yy.c -ll

testing: parser.y lexer.l
	yacc -d -v -d parser.y
	lex lexer.l
	gcc y.tab.c lex.yy.c -lfl

clean:
	rm -f *.o y.tab.c y.tab.h lex.yy.c a.out y.output
