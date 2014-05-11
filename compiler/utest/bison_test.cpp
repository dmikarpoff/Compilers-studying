#define  BOOST_TEST_MAIN
#ifndef _WIN32_
    #define BOOST_TEST_DYN_LINK
#endif

#include <boost/test/unit_test.hpp>
#include <grammar.hpp>
#include <cstdio>

#include <SyntaxTree.h>
#include <ParserHelper.h>

extern FILE* yyin;

BOOST_AUTO_TEST_SUITE(parser_suite)

BOOST_AUTO_TEST_CASE(parser_test1)
{
    yyin = fopen("../utest/data/bison_test1.test", "r");
    yyparse();
    SyntNode* ast = ParserHelper::getInstance()->ast;
    BOOST_CHECK(ast->children.size() == 2);
    SyntNode* var_decl1 = dynamic_cast<SyntNode*>(ast->children[0]);
    BOOST_CHECK(var_decl1 != NULL);
    BOOST_CHECK(var_decl1->children.size() == 3);
    TokenNode* token;
    token = dynamic_cast<TokenNode*>(var_decl1->children[0]);
    BOOST_CHECK(token != NULL && token->token == ID);
    token = dynamic_cast<TokenNode*>(var_decl1->children[1]);
    BOOST_CHECK(token != NULL && token->token == ID);
    SyntNode* var_defin10 = dynamic_cast<SyntNode*>(var_decl1->children[2]);
    BOOST_CHECK(var_defin10 != NULL);
    BOOST_CHECK(var_defin10->children.size() == 3);
    token = dynamic_cast<TokenNode*>(var_defin10->children[0]);
    BOOST_CHECK(token != NULL);
    BOOST_CHECK(token->token == EQUAL);
    token = dynamic_cast<TokenNode*>(var_defin10->children[2]);
    BOOST_CHECK(token != NULL && token->token == SEMICOL);
    SyntNode* rvalue10 = dynamic_cast<SyntNode*>(var_defin10->children[1]);
    BOOST_CHECK(rvalue10 != NULL && rvalue10->children.size() == 1);
    token = dynamic_cast<TokenNode*>(rvalue10->children[0]);
    BOOST_CHECK(token->token == NUMBER);
    SyntNode* unit2 = dynamic_cast<SyntNode*>(ast->children[1]);
    BOOST_CHECK(unit2 != NULL && unit2->children.size() == 2);
    SyntNode* var_decl3 = dynamic_cast<SyntNode*>(unit2->children[0]);
    BOOST_CHECK(var_decl3 != NULL && var_decl3->children.size() == 3);
    SyntNode* eps4 = dynamic_cast<SyntNode*>(unit2->children[1]);
    BOOST_CHECK(eps4 != NULL && eps4->children.size() == 0);
    token = dynamic_cast<TokenNode*>(var_decl3->children[0]);
    BOOST_CHECK(token != NULL && token->token == ID);
    token = dynamic_cast<TokenNode*>(var_decl3->children[1]);
    BOOST_CHECK(token != NULL && token->token == ID);
    token = dynamic_cast<TokenNode*>(var_decl3->children[2]);
    BOOST_CHECK(token != NULL && token->token == SEMICOL);
}

BOOST_AUTO_TEST_SUITE_END()
