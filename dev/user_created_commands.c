#include <stdio.h>
#include <stdlib.h>

#include "user_created_commands.h"
#include "data_structures/data_structures.h"

void execute_externel_command(linked_list * linkedlist){
	char * command;
	char ** arguments;
	char ** envp = {NULL};
	

	//count the number of elements in the linked list so we know how much memory to allocate for the array;
	int list_element_count=1;
	node * current_node;
	
	for(current_node = linkedlist->start; current_node->next != NULL; current_node=current_node->next){
		list_element_count++;
	}
	
	//allocate the memory + 1 because argument list need to end with NULL pointer
	arguments = malloc(sizeof(char *) * list_element_count + 1);
	
	int i=0;
	current_node = linkedlist->start;
	for(i=0; i<list_element_count; i++){
		arguments[i] = current_node->data;
		current_node = current_node->next;
	}
	command = arguments[0];
	

	puts(command);
	if(execve(command, arguments, envp)<0){
		puts("execve has failed");
	}


<<<<<<< Updated upstream
}

void pop_alias_list(linked_list * linkedlist, char * data){
        //this function will pop the element that contains "data"
        node * current_node;
        node * next_node;
	node * prev_node;
	prev_node = NULL;
        current_node = linkedlist->start;       //grab the first node
	next_node = current_node->next;		//grab the next node
        while(current_node!=NULL){
                //search the full list
		if(((alias_node *)(current_node->data))->alias_name == data){
			//pop
			prev_node->next = next_node;
			break;
		}
		else{
			//go to next node
			prev_node = current_node;
			current_node = current_node->next;
			next_node = next_node->next;
		}
        }
=======
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
		
		if(!(p = strstr(str, orig))){
			return str; //is orig actually in str
		}
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
//			puts(first_arg);
//			puts("is checking against:");
//			puts(alias_list_pointer->name_of_node);
			char * blah = strtok(strdup(alias_list_pointer->name_of_node)," ");
//			printf("%i\n",strcmp(first_arg,blah));
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
	
//	printf("The replaced buffer is %s\n",return_buff);
	if(alias_pres){
		return return_buff;
	}
	else{
		return NULL;
	}
>>>>>>> Stashed changes
}

void print_alias_list(linked_list * linkedlist){
	node * current_node = linkedlist->start;
	
	char * tmp_alias_name;
	char * tmp_value;
	
	while(current_node != NULL){
		tmp_alias_name = ((alias_node *)(((node *)(current_node->data))->data))->alias_name;
		tmp_value = ((alias_node *)(((node *)(current_node->data))->data))->value;
		
<<<<<<< Updated upstream
		printf("%s=%s\n", tmp_alias_name, tmp_value);
		
		current_node = current_node->next;
	}
	
=======
	return_buffer = check_for_alias(aliaslist, buffer);	
	
	while(return_buffer!=NULL){
		buffer = return_buffer;
		return_buffer = check_for_alias(aliaslist,return_buffer);
	}

	return buffer;
>>>>>>> Stashed changes
}



