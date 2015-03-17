
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

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

%union {char * string; int num;}
%token EXIT CHANGE_DIR
%token <string> FILE_NAME

%%

commands: /* empty */
        | commands command{
			printf("%s","$ ");
		}
        ;

command:
        cd
        |
        exit
        ;

cd:
        CHANGE_DIR FILE_NAME
        {
            chdir($2);
            system("/bin/ls"); //print directory for debugging
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

%%
