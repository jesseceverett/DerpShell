
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "data_structures/data_structures.h"
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}

int yywrap(){
    return 1;
}

int main(){
    puts("|--------Welcome to derp shell!--------|"); 
	puts(" By: Vincent Moscatello, Jesse Everett");
	printf("%s","$ ");
	yyparse();
}

%}

%union {char * string; int num; void * linkedlist;}
%token EXIT CHANGE_DIR NEW_LINE
%token <string> FILE_NAME

%left CHANGE_DIR FILE_NAME
%type <linkedlist> arg_list
%type <string> arg


%%

commands: /* empty */
        | commands command{
			printf("%s","$ ");
		}
        ;
//command: sub_command NEW_LINE
//	   	{ $$ = $1;}

command:
	   NEW_LINE
	   |
        cd NEW_LINE
        |
        exit NEW_LINE
		|
		cmd NEW_LINE
		;

cd:
        CHANGE_DIR FILE_NAME
        {
            chdir($2);
            free($2); //since we used strdup on yytext
        }
        ;


exit:
        EXIT
        {
                printf("Goodbye for now!!!!\n");
                exit(0);
        }
        ;
cmd:
   		arg_list
		{
			
			print_linked_list($1);
			system("/bin/ls");
			
		}
		;
arg_list:
		arg{ linked_list* ll = create_linked_list();
			push_linked_list(ll,$1);
			$$=ll;}
		|
		arg_list arg{push_linked_list($1,$2); $$ = $1;}
	
arg: FILE_NAME{$$=$1;}
%%

