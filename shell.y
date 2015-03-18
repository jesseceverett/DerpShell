
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
		|
		cmd
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
   		FILE_NAME
		{
			pid_t pid = fork();
			
			if(pid == 0){
				char * subproc_argv[2];
				subproc_argv[0] = $1;
				subproc_argv[1] = NULL;

				char * envp[] = {NULL};

				if(execve($1, subproc_argv, envp)==-1){
					puts("execve has failed");
				}
			}else{
				int status;
				waitpid(pid, status, NULL);
			
			}
			
			free($1);
			
		}

%%
