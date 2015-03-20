#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H
typedef struct node{
	char * data;
	struct node * next;
} node;

typedef struct linked_list{
	struct node * start;
	struct node * end;
} linked_list;

void free_linked_list(linked_list * linked_list);

#endif
