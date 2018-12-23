%{
#include <stdio.h>
%}

%option noyywrap

%%
"HELLO\n" { printf("Hello, world!\n"); }
.|\n      { }
%%

int main(int argc, char **argv) {
#ifdef __cplusplus
    yyFlexLexer lexer;
    while(lexer.yylex() != 0) {}
#else
    yylex();
#endif
    return 0;
}
