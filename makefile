all: parser.y lexer.l
	bison -d parser.y
	flex lexer.l
	gcc pile.c symbols_tab.c varArray.c variables_tab.c parser.tab.c lex.yy.c -o scalpa

clean:
	rm -rf *.o parser.tab.c parser.tab.h lex.yy.c a.out y.output scalpa
