all: parser.y lexer.l
	yacc -d -v -d parser.y
	lex lexer.l
	gcc y.tab.c lex.yy.c -Wall -o scalpa

clean:
	rm -f *.o y.tab.c y.tab.h lex.yy.c a.out y.output scalpa
