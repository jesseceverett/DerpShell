#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "user_created_commands.h"
#include "data_structures/data_structures.h"

void execute_externel_command(linked_list * linkedlist){
	char * command;
	char ** arguments;
	char ** envp = {NULL};
	

	//count the number of elements in the linked list so we know how much memory to allocate for the array;
	int list_element_count=0;
	node * current_node;
	
	for(current_node = linkedlist->start; current_node != NULL; current_node=current_node->next){
		list_element_count++;
	}
	list_element_count++;	//add an extra number to the element count to ensure the last one is NULL
	
	//allocate the memory + 1 because argument list need to end with NULL pointer
	arguments = calloc(sizeof(char *), list_element_count);
	
	//now we put the char* into actually point to data
	int i=0;
	current_node = linkedlist->start;
	for(i=0; i<list_element_count-1; i++){		//we use count-1 to allow the last element to stay NULL
		arguments[i] = current_node->data;
		current_node = current_node->next;
	}
	//we need to assign the command 
	//which is the first element of arguments
	command = arguments[0];

	execve(command, arguments, envp);
	exit(0);	
}


/*
 *Will return 0 if executable can be successfully found in path
 */
int executable_in_path(linked_list * linkedlist){
	char * heap_path_env;
	heap_path_env = strdup(getenv("PATH"));
	char * tmp_path = NULL;
	char * tmp_var;

	tmp_path = strtok(heap_path_env, ":");
	tmp_var = malloc(strlen(tmp_path)+1);
	strcpy(tmp_var, tmp_path);
	
	while(tmp_path != NULL){
		char * slash = malloc(sizeof(char));
		*slash = '/';
		strcat(tmp_var, slash); 
		strcat(tmp_var, strdup(linkedlist->start->data));
		if(access(tmp_var, X_OK)==0){
			linkedlist->start->data = tmp_var;
			return 0;
		}
		free(slash); 
		tmp_path = strtok(NULL, ":");
		if(tmp_path != NULL){
			tmp_var = malloc(strlen(tmp_path)+1);
			strcpy(tmp_var, tmp_path);
		}

	}


	return -1;
	
	
}

void push_alias_name(linked_list * aliaslist, char * name, char * value){
        //check for infinite alias expansion
        //i.e. if something points back to itself immediatly or thorugh a chain

        int err = 0;
        node * current_node = aliaslist->start;
        while(current_node != NULL){
                if(strcmp(current_node->name_of_node,value) == 0){
                //if user is trying to set the value of a new alias to a name of an existing alias
                //then err
                        printf("Infinite alias expansion detected. Stop.\n");
                        err = 1;
                        break;
                }
                if(strcmp(current_node->name_of_node,name) == 0){
                        printf("That name is already aliased. Stop\n");
                        err = 1;
                        break;
                }
                current_node = current_node->next;
        }

        if(strcmp(name,value)==0){
                //you can't alias yourself
                printf("No! You can't make %s equal itself!\n",name);
                err = 1;

        }

        if(!err){
                push_linked_list(aliaslist, value);
                aliaslist->end->name_of_node = name;
        }
}


void print_alias_list(linked_list * aliaslist){
	node * current_node = aliaslist->start;
	while(current_node != NULL){
		printf("%s=%s\n", current_node->name_of_node, current_node->data);
		current_node = current_node->next;
	}
}

int remove_alias_name(linked_list * aliaslist, char * name){
	if(aliaslist->start==NULL){
		return -1;
	}
	
	node * current_node = aliaslist->start;
	node * next_node = current_node->next;
	node * prev_node = NULL;
	
	while(current_node != NULL){
		if(strcmp(current_node->name_of_node, name)==0){
			if(prev_node == NULL){
				aliaslist->start = next_node;
			}
			else if (next_node == NULL){
				aliaslist->end = prev_node;
				prev_node->next = NULL;
			}
			else{
				prev_node->next = next_node;
			}
			free(current_node);
			break;
		}
		prev_node = current_node;
		current_node = current_node->next;
		next_node = current_node->next;
	

	}
}

char *replace(char *str, char *orig, char * rep)
{
		static char buffer[4096];
		char *p;
		
		if(!(p = strstr(str, orig))) return str; //is orig actually in str
					
		strncpy(buffer, str, p-str); //copy char from str start to orig into buffer
		buffer[p-str] = '\0';
							
		sprintf(buffer+(p-str), "%s%s", rep, p+strlen(orig));
								
		return buffer;
}




char * check_for_alias(linked_list * aliaslist,char * buffer){
	char * command;
	char * command_copy;
	char * first_arg;

	int found = 0;
	int alias_pres = 0;
	
	linked_list * command_linkedlist = create_linked_list(); //create a list for the commands
	
	command_copy = malloc(strlen(buffer)+1);
	strcpy(command_copy, buffer);			//malloc the memory and make a copy of our input

	command = strtok(command_copy, "|");
	do{
		command = strdup(command);
		push_linked_list(command_linkedlist, command);
	}while((command = strtok(NULL,"|"))!=NULL);
	//seperate command_copy (buffer) by the '|' character
	//and put each token into command_linkedlist


	node * command_list_pointer=command_linkedlist->start;
	

	while(command_list_pointer != NULL){

		char * dummy = strchr(strdup(command_list_pointer->data),' ');
		if(dummy == NULL){
			first_arg = strdup(command_list_pointer->data);
			if (first_arg[strlen(first_arg)-1] == '\n') {
				first_arg[strlen(first_arg)-1] = '\0';
			}
		}
		else{
			first_arg=strtok(strdup(command_list_pointer->data)," "); //grab the first word of the node	
		}
		
		node * alias_list_pointer = aliaslist->start; //grab the first alias
		found = 0;
		while((alias_list_pointer != NULL) && (!found)){
			char * blah = strtok(strdup(alias_list_pointer->name_of_node)," ");
			if(strcmp(first_arg,blah) == 0){ //if the first word of a command has an alias then substitute it
				char * tmp = replace(command_list_pointer->data,first_arg,alias_list_pointer->data );
				command_list_pointer->data = tmp;
				found = 1;
				alias_pres = 1;
			}
			alias_list_pointer = alias_list_pointer->next;	
		}
		command_list_pointer = command_list_pointer->next;
	}
	
	//replace the values in each node of command_linkedlist with a possible alias

	node * tmp_ptr = command_linkedlist->start;
	char * return_buff = NULL;
	return_buff = strdup(tmp_ptr->data);
	if(tmp_ptr->next != NULL){
		strcat(return_buff,strdup(" |"));
	}
	tmp_ptr = tmp_ptr->next;
	while(tmp_ptr != NULL){
		strcat(return_buff,strdup(tmp_ptr->data));
		if(tmp_ptr->next != NULL){
			strcat(return_buff,strdup(" |"));
		}
		tmp_ptr = tmp_ptr->next;
	}
	
	if(alias_pres){
		return return_buff;
	}
	else{
		return NULL;
	}
}

char * check_for_env(char * buffer){
	char * start_pointer;
	char * end_pointer;
	char env_buffer[1024];
	char environment;
	
	char * return_buffer;
	char * return_buffer_refrence;

	if((start_pointer = strchr(buffer, '$')) != NULL){
		if(*(start_pointer + 1) == '{'){
			end_pointer = strchr(start_pointer+2,'}');
			//Handle the actual replacement
			int size_to_read = end_pointer-start_pointer-2;
			//write(1,start_pointer, size);
			
			strncpy(env_buffer, start_pointer+2, size_to_read);
//			puts(env_buffer);
			if(getenv(env_buffer) == NULL){
				puts("That directory doesn't exist");
				return NULL;
			}
//			puts(getenv(env_buffer));
			
			return_buffer = malloc(1024);
			
			int up_to_size_pointer = start_pointer - buffer + 1;
			strncpy(return_buffer, buffer, up_to_size_pointer-1);
			return_buffer_refrence =&buffer[up_to_size_pointer];
			
			return_buffer = strcat(return_buffer, getenv(env_buffer));
			return_buffer_refrence = &return_buffer[strlen(return_buffer)-1];
			
			strncpy(return_buffer_refrence+1, end_pointer+1, strlen(end_pointer)-1);

//			puts(return_buffer);

			return return_buffer;
		}
		else{
			return NULL;
		}
	}
	
	return NULL;
}

char * check_for_ampersand(char * buffer){
	return strchr(buffer,'&');
}

char * replace_token(linked_list * aliaslist, char * buffer){
	char * return_buffer= check_for_env(buffer);
	
	while(return_buffer!=NULL){	
		buffer = return_buffer;
		return_buffer = check_for_env(return_buffer);
	}
		
	return_buffer = check_for_alias(aliaslist, buffer);
	while(return_buffer!=NULL){
		buffer = return_buffer;
		return_buffer = check_for_alias(aliaslist,return_buffer);
	}
	
	//puts(buffer);
	return buffer;
}

char * remove_quotes(char * buffer){
	char * return_buffer = malloc(strlen(buffer));
	int i, j;
	for(i=0;i<strlen(buffer);i++){
		if(buffer[i] != '"'){
			return_buffer[j++] = buffer[i];
		}
	}
	return_buffer[j] = '\0';
	return return_buffer;
}

void handle_signal(){
	puts("Use bye to exit shell!!!");
}


