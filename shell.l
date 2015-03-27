%{
#include <stdio.h>
#include "y.tab.h"
%}

%%

cd                      return CHANGE_DIR;
bye                     return EXIT;
setenv					return SET_ENV;
printenv				return PRINT_ENV;
alias			return ALIAS;
unalias			return UNALIAS;

[a-zA-Z0-9\/.-]+        yylval.string = strdup(yytext); return FILE_NAME;

\n                      return NEW_LINE;
[ \t]+                  /* ignore whitespace */;

%%
