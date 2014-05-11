#define  BOOST_TEST_MAIN
#ifndef _WIN32_
	#define BOOST_TEST_DYN_LINK
#endif

#include <boost/test/unit_test.hpp>
#include <fstream>
#include <grammar.h>

extern int yylex();
extern FILE* yyin;

BOOST_AUTO_TEST_SUITE(lexical_suite)

BOOST_AUTO_TEST_CASE(lex_test1)
{
    yyin = fopen("../utest/data/lex_test1.test", "r");
    BOOST_CHECK(yyin != NULL);
    std::vector<int> tokens;
    int token = 0;
    token = yylex();
    while (token != 0)
	{
        tokens.push_back(token);
        token = yylex();
	}
	fclose(yyin);
    BOOST_CHECK_EQUAL(tokens.size(), 20);
    BOOST_CHECK_EQUAL(tokens[0], ID);
    BOOST_CHECK_EQUAL(tokens[1], SEMICOL);
    BOOST_CHECK_EQUAL(tokens[2], ID);
    BOOST_CHECK_EQUAL(tokens[3], SEMICOL);
    BOOST_CHECK_EQUAL(tokens[4], ID);
    BOOST_CHECK_EQUAL(tokens[5], ID);
    BOOST_CHECK_EQUAL(tokens[6], NUMBER);
    BOOST_CHECK_EQUAL(tokens[7], NUMBER);
    BOOST_CHECK_EQUAL(tokens[8], ID);
    BOOST_CHECK_EQUAL(tokens[9], NUMBER);
    BOOST_CHECK_EQUAL(tokens[10], NUMBER);
    BOOST_CHECK_EQUAL(tokens[11], NUMBER);
    BOOST_CHECK_EQUAL(tokens[12], NUMBER);
    BOOST_CHECK_EQUAL(tokens[13], NUMBER);
    BOOST_CHECK_EQUAL(tokens[14], NUMBER);
    BOOST_CHECK_EQUAL(tokens[15], NUMBER);
    BOOST_CHECK_EQUAL(tokens[16], NUMBER);
    BOOST_CHECK_EQUAL(tokens[17], ID);
    BOOST_CHECK_EQUAL(tokens[18], ID);
    BOOST_CHECK_EQUAL(tokens[19], NUMBER);
}

BOOST_AUTO_TEST_SUITE_END()
