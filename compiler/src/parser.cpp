#include <cstdio>
#include <iostream>
#include <grammar.hpp>
#include <SyntaxTree.h>
#include <ParserHelper.h>

extern "C" FILE* yyin;

void exportAST(SyntNode* ast)
{

}

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cout << "Specify exactly ONE input file" << std::endl;
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL)
    {
        std::cout << "Can not open specified file" << std::endl;
        return 1;
    }
    yyparse();
    SyntNode* ast = ParserHelper::getInstance()->ast;

    return 0;
}
