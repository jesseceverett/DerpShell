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
}

