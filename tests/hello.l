%{
#include <stdio.h>
%}

%option noyywrap

%%
"HELLO\n" { printf("Hello, world!\n"); }
.|\n      { }
%%

int main(int argc, char **argv) {
    yylex();
    return 0;
}
