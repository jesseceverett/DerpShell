# DerpShell
COP4600 Shell project for Dr. Sumi Helal Spring 2015

Submission by:  Vincent Moscatello
                Jesse Everett

##Summary of Files:
  To help keep the project organized some of the code that drives the shell is kept seperate from the lex and yacc files
  shell.y and shell.l. These files can be found in the directory dev.
    
  As opposed to a main.c we have composed extra c functionality into a file called dev/
  this contains
  **dev/data_structures/*** contains the implementation for important data structures such as a linked list.
  **dev/user_created_commands.c** contains the implementation of user created functions such as execute_externel_command
  that would have created too much clutter in the file yacc.
  
##Curently Working:
  setenv
  unsetenv
  printenv
  cd
  bye
  unalias
  alias
  as well as just typing a command such as "ls" or "cat xx" will search the entire path to find "/bin/ls" and execute that appropriatly
  
##Not Working:
  I/O redirection
  Metacharacters (wildcards and such)
  Tilde expansion
  
  
  
