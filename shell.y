
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
				//Lets first count the number of words so we know how much space to allocate for
				//command_argv array
				int i =0;
				unsigned int command_count=0;
				for(i=0; $1[i]!='\x00'; i++){
					if($1[i]==' '){
						command_count++;
					}
				}
				command_count=command_count +2;
				
				//Allocate enough space on the heap for the pointers to command arguments.
				char ** command_array = malloc(sizeof(char *)*command_count);

				//Run strtok to tokenize the command arguments 
				char * command = strtok($1," ");
				
				//assign the paramters to command to command_array 
				char * foo;
				unsigned int index=0;
				for(foo = command; foo; foo = strtok(NULL, " ")){
					if(index >= command_count)
						break;
					command_array[index] = foo;
					index++;
				}

				//envp is not used but is necissary for execve syscommand
				char * envp[] = {NULL};

				if(execve($1, command_array, envp)==-1){
					puts("execve has failed");
				}
			}else{
				int status;
				waitpid(pid, status, NULL);
			
			}
			
			free($1);
			
		}
		;



%%
