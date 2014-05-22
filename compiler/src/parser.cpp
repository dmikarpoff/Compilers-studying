#include <cstdio>
#include <iostream>
#include <grammar.hpp>
#include <SyntaxTree.h>
#include <ParserHelper.h>
#include <stack>
#include <sstream>
#include <graphviz/gvc.h>

extern "C" FILE* yyin;

void exportAST(SyntNode* ast, char* source, char* out)
{
    std::cout << "-------------------------" << std::endl;
    std::cout << "export START" << std::endl;
    GVC_t* gvc;
    std::stack<SuperNode*> stack;
    std::stack<Agnode_t*> gstack;
    stack.push(ast);
    Agraph_t* gast;
    size_t counter = 0;
    gast = agopen(source, Agdirected, 0);
    std::string tmp_str = ast->text + " (0)" +  '\0';
    gstack.push(agnode(gast, &tmp_str[0], 1));
    while (! stack.empty())
    {
        SuperNode* cur_node = stack.top();
        Agnode_t* gnode = gstack.top();
        stack.pop();
        gstack.pop();
        std::cout << "cur_node: " << cur_node << std::endl;
        SyntNode* node = dynamic_cast<SyntNode*>(cur_node);
        std::cout << "cast successfull" << std::endl;
        std::cout << node << std::endl;
        if (cur_node != NULL)
            std::cout << cur_node->text << ": ";
        std::cout.flush();
        if (node != NULL && node->children.size() != 0)
        {
            std::cout << node->children.size() << std::endl;
            for (size_t i = 0; i < node->children.size(); ++i)
            {
                ++counter;
                std::stringstream conv;
                conv << counter;
                std::cout << node->children[i] << std::endl;
                TokenNode* tn = static_cast<TokenNode*>(node->children[i]);
                std::cout << tn << std::endl;
                if (tn != NULL)
                    std::cout << tn->token << std::endl;
                std::cout << node->children[i]->text << " ";
                std::cout.flush();
                stack.push(node->children[i]);
                tmp_str = node->children[i]->text + " (" + conv.str() + ")" + '\0';
                Agnode_t* next = agnode(gast, &tmp_str[0], 1);
                gstack.push(next);
                agedge(gast, gnode, next, 0, 1);
            }
        }
        std::cout << std::endl;
    }
    gvc = gvContext();
    gvLayout(gvc, gast, "dot");
    FILE* outFile = fopen(out, "w");
    if (outFile == NULL)
    {
        std::cout << "Unable write to file: " << out << std::endl;
        return;
    }
    gvRender(gvc, gast, "ps", outFile);
    gvFreeLayout(gvc, gast);
    fclose(outFile);
    std::cout << "export FINISH" << std::endl;
}

int main(int argc, char** argv)
{
    if (argc != 3)
    {
        std::cout << "Illegal format!" << std::endl;
        std::cout << "Use format: parser <input file> <output file>" <<  std::endl;
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL)
    {
        std::cout << "Can not open specified file" << std::endl;
        return 1;
    }
    std::cout << "parsing START" << std::endl;
    yyparse();
    std::cout << "parsing FINISH" << std::endl;
    SyntNode* ast = ParserHelper::getInstance()->ast;
    exportAST(ast, argv[1], argv[2]);
    return 0;
}
