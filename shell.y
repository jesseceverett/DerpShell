
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
    yyparse();
}

%}

%union {char * string; int num;}
%token EXIT CHANGE_DIR
%token <string> FILE_NAME

%%

commands: /* empty */
        | commands command
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
                printf("\tTerminating Session!!!\n");
                exit(0);
        }
        ;

%%
