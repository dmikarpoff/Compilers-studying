#include <iostream>
#include <cstdio>
#include <LexHelper.h>

extern FILE* yyin;
extern int yylex();

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cout << "There are " << argc - 1 << " arguments! Should be exactly ONE" << std::endl;
        return -1;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL)
    {
        std::cout << "Can't open file " << argv[1] << std::endl;
        return -1;
    }
    int token = yylex();
    while (token != 0)
    {
        std::cout << LexHelper::tokenToString(token) << " ";
        token = yylex();
    }
    std::cout << std::endl;
    fclose(yyin);
    return 0;
}
