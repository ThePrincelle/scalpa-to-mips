all: parser.y lexer.l
	yacc -d -v -d parser.y
	lex lexer.l
	gcc y.tab.c lex.yy.c pile.c symbols_tab.c -Wall -o scalpa

clean:
	rm -rf *.o y.tab.c y.tab.h lex.yy.c a.out y.output scalpa temp
