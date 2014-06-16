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
        SyntNode* node = dynamic_cast<SyntNode*>(cur_node);
        if (node != NULL && node->children.size() != 0)
        {
//            std::cout << "Synt node proccessing" << std::endl;
//            std::cout << node->text << std::endl;
//            std::cout << "size = " << node->children.size() << std::endl;
            for (size_t i = 0; i < node->children.size(); ++i)
            {
//                std::cout << node->children[i]->text << std::endl;
                ++counter;
                std::stringstream conv;
                conv << counter;
                stack.push(node->children[i]);
                tmp_str = node->children[i]->text + " (" + conv.str() + ")" + '\0';
                Agnode_t* next = agnode(gast, &tmp_str[0], 1);
                gstack.push(next);
                agedge(gast, gnode, next, 0, 1);
            }
//            std::cout << "Synt node proccessing FINISH" << std::endl;
            continue;
        }
        BynaryOp* op_node = dynamic_cast<BynaryOp*>(cur_node);
        if (op_node != NULL)
        {
//            std::cout << "Bynary op proccessing" << std::endl;
            ++counter;
            std::stringstream conv;
            conv << counter;
            stack.push(op_node->left);
            tmp_str = op_node->left->text + " (" + conv.str() + ")" + '\0';
            Agnode_t* next = agnode(gast, &tmp_str[0], 1);
            gstack.push(next);
            agedge(gast, gnode, next, 0, 1);
            if (op_node->right != NULL) {
                conv.str("");
                ++counter;
                conv << counter;
                stack.push(op_node->right);
                tmp_str = op_node->right->text + " (" + conv.str() + ")" + '\0';
                next = agnode(gast, &tmp_str[0], 1);
                gstack.push(next);
                agedge(gast, gnode, next, 0, 1);
            }
//            std::cout << "Bynary op proccessing FINISH" << std::endl;
            continue;
        }
        UnaryOp* un_node = dynamic_cast<UnaryOp*>(cur_node);
        if (un_node != NULL) {
            ++counter;
            std::stringstream conv;
            conv << counter;
            stack.push(un_node->operand);
            tmp_str = un_node->operand->text + " (" + conv.str() + ")" + '\0';
            Agnode_t* next = agnode(gast, &tmp_str[0], 1);
            gstack.push(next);
            agedge(gast, gnode, next, 0, 1);
        }
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
    std::cout << "compile..." << std::endl;
    yyparse();
    int* counters = ParserHelper::getInstance()->error_count;
    int total_error = counters[0] + counters[1] + counters[2];
    if (total_error == 0) {
        std::cout << "...successful" << std::endl;
        SyntNode* ast = ParserHelper::getInstance()->ast;
        exportAST(ast, argv[1], argv[2]);
    } else {
        std::cout << "... compilation failed with " <<
                     total_error << " errors" << std::endl;
    }
    return 0;
}
