%{
#include <stdio.h>
#include "tests/hello_common.h"
%}

%option noyywrap

%%
"HELLO\n" { hello_common(); printf("Hello, world!\n"); }
.|\n      { }
%%
