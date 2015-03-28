
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "dev/data_structures/data_structures.h"
#include "dev/user_created_commands.h"


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
%token EXIT CHANGE_DIR NEW_LINE SET_ENV PRINT_ENV UNSET_ENV
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
		|
		set_env NEW_LINE
		|
		print_env NEW_LINE
		|
		unset_env NEW_LINE
		;

/********************************************************************************************
 *
 *The following section describes built in commands such as cd, alias, and setenv
 *
 ********************************************************************************************/


cd:
		CHANGE_DIR{chdir(getenv("HOME"));}
		|
		CHANGE_DIR FILE_NAME
		{
			chdir($2);
			free($2); //since we used strdup on yytext
		}
		;

set_env:
		SET_ENV FILE_NAME FILE_NAME
		{
			setenv($2, $3,1);
		}

print_env:
		PRINT_ENV
		{

			extern char **environ;
			char ** current_value = environ;
			for(;*current_value != NULL; current_value++){
				puts(*current_value);
			}
		}

unset_env:
		UNSET_ENV FILE_NAME
		{
			unsetenv($2);
		}

exit:
		EXIT
		{
			printf("Goodbye for now!!!!\n");
			exit(0);
		}
		;


/********************************************************************************************
 *
 *The following section, cmd, arg_list, and arg describe the functionality of "other commands"
 *(commands defined outside of the shell) ex: /bin/ls -l
 *
 ********************************************************************************************/

cmd:
		arg_list
		{
			
			//check if the command can be executed. If not check if command is in PATH env
			if(access(((linked_list *)$1)->start->data, X_OK)==0){
				/*Everything is ok! break from if*/
			}
			else if(executable_in_path($1) == 0){
				/*Element found in path!*/
			}else{
				puts("Command not found!");
				goto final;
			}
			
			
			int status;
			pid_t pid = fork();

			if(pid == 0){
				//This function is defined in user_created_commands.c
				execute_externel_command($1);
				//incase command fails
				exit(0);
			}else{
				free_linked_list($1);
				waitpid(pid, &status, 0);
			}
			
			final:
				asm("nop");
		}	
		;
arg_list:
		arg{ 
			linked_list* ll = create_linked_list();
			push_linked_list(ll,$1);
			$$=ll;}
		|
		arg_list arg{push_linked_list($1,$2); $$ = $1;}
	
arg: FILE_NAME{$$=$1;}


%%

