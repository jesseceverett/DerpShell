%{
#include <stdio.h>
#include "y.tab.h"
%}

%%

cd                      return CHANGE_DIR;
exit                    return EXIT;
[a-zA-Z0-9\/.-]+        yylval.string = strdup(yytext); return FILE_NAME;

\n                      /* ignore end of line */;
[ \t]+                  /* ignore whitespace */;

%%
