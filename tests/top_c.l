%top{
#include <stdio.h>
}

%%

[0-9]+   { printf("NUMBER: %s\n", yytext); }

%%

int main(void) {
    yylex();
    return 0;
}
