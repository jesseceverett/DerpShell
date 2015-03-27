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
	arguments[1] = NULL;
	int temp_var;
	for(temp_var = 0; temp_var < list_element_count; temp_var++){
		puts(arguments[temp_var]);
	}

	printf("The command you entered was %s", command);
	printf("execve has returned %d",execve(command, arguments, envp));
	perror("ERROR HERE");	
	


}
