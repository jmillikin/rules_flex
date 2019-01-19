#include <FlexLexer.h>

int main(int argc, char **argv) {
    yyFlexLexer lexer;
    while(lexer.yylex() != 0) {}
    return 0;
}
