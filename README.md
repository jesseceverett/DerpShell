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
User defined functions:
  setenv  
  unsetenv  
  printenv  
  cd  
  bye  
  unalias: Must be accompanied by the term to unalias
                
  alias: Infinite alias expansion is not allowed, nor is aliasing something to itself
	 typing "alias" will print all aliases
CMD:
 Typing a command such as ls or cat will search PATH until the command is found and can then execute

Other:
 Path variable expansion functions
##Not Working:
  Metacharacters (wildcards and \)

##Other Notes:
 There is still some unexpected output on certain erroneous input
	i.e if something not allowed is entered it will not break the shell but it will not have a clean next line
	CTRL+C will not kill the shell, nor will faulty expressions, the only way to exit is with the "bye" command
