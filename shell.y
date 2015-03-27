
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
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
%token EXIT CHANGE_DIR NEW_LINE SET_ENV PRINT_ENV
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

exit:
		EXIT
		{
			printf("Goodbye for now!!!!\n");
			printf("MY PID IS %d\n", getpid());
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
			int status;
			pid_t pid = fork();

			printf("MY PID IS %d\n", pid);
			if(pid == 0){
				//This function is defined in user_created_commands.c
				execute_externel_command($1);
				//incase command fails
				exit(0);
			}else{
				printf("freed linked list is: %x\n",$1);
				free_linked_list($1);
				waitpid(pid, &status, 0);
			}
		}	
		;
arg_list:
		arg{ 
			linked_list* ll = create_linked_list();
			printf("allocated linked list is: %x\n",ll);
			push_linked_list(ll,$1);
			$$=ll;}
		|
		arg_list arg{push_linked_list($1,$2); $$ = $1;}
	
arg: FILE_NAME{$$=$1;}


%%

