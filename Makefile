LEX = lex
YACC = yacc
CC = gcc
shell: y.tab.o lex.yy.o data_structures.o
	$(CC) -o shell y.tab.o lex.yy.o data_structures.o
y.tab.c y.tab.h: shell.y data_structures/data_structures.h
	$(YACC) -d shell.y 
y.tab.o: y.tab.c 
	$(CC) -c y.tab.c 
lex.yy.o: y.tab.h lex.yy.c data_structures/data_structures.h
	$(CC) -c lex.yy.c 
lex.yy.c: shell.l data_structures/data_structures.h
	$(LEX) shell.l 
data_structures.o: data_structures/data_structures.c data_structures/data_structures.h
	$(CC) -c data_structures/data_structures.c
clean:
	rm *.o
	rm *.c
	rm *.h
	rm shell

