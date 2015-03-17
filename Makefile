LEX = lex
YACC = yacc
CC = gcc
shell: y.tab.o lex.yy.o
	$(CC) -o shell y.tab.o lex.yy.o
y.tab.c y.tab.h: shell.y
	$(YACC) -d shell.y
y.tab.o: y.tab.c
	$(CC) -c y.tab.c
lex.yy.o: y.tab.h lex.yy.c
	$(CC) -c lex.yy.c
lex.yy.c: shell.l
	$(LEX) shell.l
clean:
	rm *.o
	rm *.c
	rm *.h
	rm shell

