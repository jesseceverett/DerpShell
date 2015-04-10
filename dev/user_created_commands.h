#ifndef USER_CREATED_COMMANDS_H
#define USER_CREATED_COMMANSA_H
#include "data_structures/data_structures.h" 

//Executes a command defined outside of bash given a linked list. The first element of the linked list is the command and the elements that follow it are parameters to that command.
void execute_externel_command(linked_list * linkedlist);

//returns 0 if element is found in path.
int executable_in_path(linked_list * linkedlist);

int remove_alias_name(linked_list * aliaslist, char * name);
void push_alias_name(linked_list * aliaslist, char * name, char * value);
void print_alias_list(linked_list * aliaslist);

void handle_signal();

char * check_for_alias(linked_list * aliaslist, char * buffer);
char * check_for_env(char * buffer);

char * replace_token(linked_list * aliaslist, char * buffer);

char * replace(char *str, char * origin, char * rep);

char * check_for_ampersand(char * buffer);

#endif
