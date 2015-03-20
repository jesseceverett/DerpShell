%{
#include <stdio.h>
#include "y.tab.h"
#include "data_structures/data_structures.h"
%}

%%

cd                      return CHANGE_DIR;
bye                     return EXIT;
[a-zA-Z0-9\/.-]+        yylval.string = strdup(yytext); return FILE_NAME;

\n                      return NEW_LINE;
                  /* ignore whitespace */;

%%
