%{
#include <stdio.h>
#include "y.tab.h"
%}

%%

cd                     			return CHANGE_DIR;
bye                     		return EXIT;
setenv					return SET_ENV;
unsetenv				return UNSET_ENV;
printenv				return PRINT_ENV;
alias					return ALIAS;
unalias					return UNALIAS;
[|]					return PIPE;
[<]					return LT;
[>]					return GT;

\".*\" {
    yylval.string = (char*)calloc(strlen(yytext)-1, sizeof(char));
    strncpy(yylval.string, &yytext[1], strlen(yytext)-2);
    return STRINGLITERAL;
}					

[a-zA-Z0-9\/.-]+        yylval.string = strdup(yytext); return FILE_NAME;

\n                      return NEW_LINE;
[ \t]+                  /* ignore whitespace */;

%%
