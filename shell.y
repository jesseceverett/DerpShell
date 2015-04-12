
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <dirent.h>
#include "dev/data_structures/data_structures.h"
#include "dev/user_created_commands.h"

linked_list * aliases;
char * is_ampersand_present;

void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}

int yywrap(){
    return 1;
}

int main(){
//    signal(SIGINT, handle_signal);
	
	puts("|--------Welcome to derp shell!--------|"); 
	puts(" By: Vincent Moscatello, Jesse Everett");
	aliases = create_linked_list();
	DIR *d;
	struct dirent *dir;
	char * return_buffer;
	char * dummy_buffer;
//	d = opendir(".");
	while(1){
		is_ampersand_present=NULL;
		printf("%s","$ ");
		char buffer[1024];
		fgets(buffer,1024,stdin);
		strcpy(buffer,replace_token(aliases,buffer));
		is_ampersand_present = check_for_ampersand(buffer);
		strcpy(buffer,replace(buffer,"~",getenv("HOME")));
		yy_switch_to_buffer(yy_scan_string(buffer));
		yyparse();
	}
}

%}

%union {char * string; int num; void * linkedlist;}
%token EXIT CHANGE_DIR NEW_LINE SET_ENV PRINT_ENV UNSET_ENV ALIAS UNALIAS PIPE LT GT
%token <string> FILE_NAME STRINGLITERAL

%left CHANGE_DIR FILE_NAME
%type <linkedlist> arg_list
%type <string> arg


%%

//command: sub_command NEW_LINE
//	   	{ $$ = $1;}

//commands:
//				| commands command
//				{				
//					printf("%s$ ",getenv("PWD"));
//				};
														

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
		|
		alias NEW_LINE
		|
		unalias NEW_LINE
		;

/********************************************************************************************
 *
 *The following section describes built in commands such as cd, alias, and setenv
 *
 ********************************************************************************************/


cd:
		CHANGE_DIR{chdir(getenv("HOME"));}
		|
		CHANGE_DIR arg
		{
			chdir($2);
			free($2); //since we used strdup on yytext
		}
		;

set_env:
		SET_ENV arg arg
		{
			setenv($2, $3,1);
		}
		;
print_env:
		PRINT_ENV
		{

			extern char **environ;
			char ** current_value = environ;
			for(;*current_value != NULL; current_value++){
				puts(*current_value);
			}
		}
		;
unset_env:
		UNSET_ENV arg
		{
			unsetenv($2);
		}
		;
alias:
		ALIAS{
			print_alias_list(aliases);
		}
		|
		ALIAS arg arg{
			push_alias_name(aliases, $2, $3);
		}
		;
unalias:
		UNALIAS arg{
			remove_alias_name(aliases, $2);
		}
		;
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
				if(is_ampersand_present==NULL){
					waitpid(pid, &status, 0);
				}
			}
			
			final:
				asm("nop");
		}	
		|
		arg_list PIPE arg_list
		{	
			int i;
			int status;
			
			pid_t pid[2];
			int ab[2];
			
			linked_list * argv1 = $1;
			linked_list * argv2 = $3;
			
			if(((executable_in_path($1) == 0) || access(((linked_list *)$1)->start->data, X_OK)==0) && ((access(((linked_list *)$3)->start->data, X_OK)==0) || (executable_in_path($3) == 0))){
				/*Everything is ok! break from if*/
			}
			else{
				puts("Command not found!");
				goto final;
			}

			pipe(ab);
			pid[0] = fork();
			if(pid[0] == 0){
				dup2(ab[1],1);
				for(i=0;i<1;i++){
					close(ab[i]);
				}
				execute_externel_command(argv1);
				exit(0);
			}
			
			pid[1] = fork();
			if(pid[1] == 0){
				dup2(ab[0],0);
				for(i=0;i<1;i++){
					close(ab[i]);
				}
				execute_externel_command(argv2);
				
				exit(0);
			}


			for(i=0;i<1;i++){
				close(ab[i]);
			}
			
			waitpid(-1, NULL, 0);
		}
		|
		arg_list LT arg
		{
			//accept input from a file	
			int fd;
			char * file = $3;
			pid_t pid;

			if((executable_in_path($1)==0) || access(((linked_list *)$1)->start->data, X_OK)==0){
                        }
                        else{
                                puts("Command not found!");
                                goto final;
                        }
			
			fd = open(file, O_RDONLY);
			if(fd == -1){
				puts("Error, could not open file");
				goto final;
			}
			
		//	close(fd);
			pid = fork();
			if(pid == 0){
				dup2(fd,0);
				execute_externel_command($1);
				exit(0);
			}
			else{
				waitpid(-1, NULL, 0);
			}

		}
		|
		arg_list GT arg
		{
			//redirect STDOUT to file
			int fd;
                        char * file = $3;
                        pid_t pid;
			if((executable_in_path($1)==0) || access(((linked_list *)$1)->start->data, X_OK)==0){
			}
			else{
				puts("Command not found!");
				goto final;
			}
			if(access(file, F_OK) != 0){
				fclose(fopen($3,"w"));
			}else{
				remove($3);	
				fclose(fopen($3,"w"));
			}	
			
			//If the file doens't exist, make and close it
			fd = open(file, O_WRONLY);
                        if(fd == -1){
                                puts("Error, could not open file");
                                goto final;
                        }

                //      close(fd);
                        pid = fork();
                        if(pid == 0){
                                dup2(fd,1);
                                execute_externel_command($1);
                                exit(0);
                        }
                        else{
				close(fd);
                                waitpid(-1, NULL, 0);
                        }			
		}
		|
		arg_list GT GT arg
		{
			//redirect STDOUT to file
                        int fd;
                        char * file = $4;
                        pid_t pid;
                        if((executable_in_path($1)==0) || access(((linked_list *)$1)->start->data, X_OK)==0){
                        }
                        else{
                                puts("Command not found!");
                                goto final;
                        }
                        if(access(file, F_OK) != 0){
                                fclose(fopen($4,"w"));
                        }
			
			

                        //If the file doens't exist, make and close it
                        fd = open(file, O_WRONLY | O_APPEND);
                        if(fd == -1){
                                puts("Error, could not open file");
                                goto final;
                        }

                //      close(fd);
                        pid = fork();
                        if(pid == 0){
                                dup2(fd,1);
                                execute_externel_command($1);
                                exit(0);
                        }
                        else{
                                close(fd);
                                waitpid(-1, NULL, 0);
                        }

		}
		;
arg_list:
		arg{ 
			linked_list* ll = create_linked_list();
			push_linked_list(ll,$1);
			$$=ll;}
		|
		arg_list arg{push_linked_list($1,$2); $$ = $1;}
		;
arg: 
	FILE_NAME
	{
		$$=$1;
	}
	|
	STRINGLITERAL
	{
		$$=$1;
	}
	;

%%

