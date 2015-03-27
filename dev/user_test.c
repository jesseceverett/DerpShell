#include <stdio.h>
#include <stdlib.h>
#include "user_created_commands.h"
int main(){
	linked_list * linkedlist = create_linked_list();
	//declare alias node
	alias_node * new_node = malloc(sizeof(node));
	new_node->alias_name = "Jesse";
	new_node->value = "is a dumbass";
	push_linked_list(linkedlist,new_node);
	print_linked_list(linkedlist);
}
