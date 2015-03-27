#include <stdio.h>
#include <stdlib.h>

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
	
	printf("list_element_count has value %d\n", list_element_count);
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

	//int temp_var;
	//for(temp_var = 0; temp_var < list_element_count; temp_var++){
	//	puts(arguments[temp_var]);
	//}

	printf("The command you entered was %s", command);
	printf("execve has returned %d",execve(command, arguments, envp));
	perror("ERROR HERE");	
	


}
