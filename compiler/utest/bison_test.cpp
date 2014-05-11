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
}

BOOST_AUTO_TEST_SUITE_END()
