#include "data_structures.h"

//Function for freeing
void free_linked_list(linked_list * linked_list){
    node * current_node;
    node * next_current_node;
    current_node = linked_list->start;
    while(current_node->next != NULL){
        //release string pointed to by a node
        free(current_node->data);
        next_current_node = current_node->next;

        //free the node itself
        free(current_node);
        current_node = next_current_node;
    }
}
