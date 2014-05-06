%{

#include "../bison/grammar.hpp"
#include <LexHelper.h>
#include <SyntaxTree.h>
#include <sstream>
#include <iostream>

void initScanner();

#define YY_USER_INIT initScanner()

%}

digit 				[0-9]
letter 				[a-zA-Z]
number				(([-+]?{digit}+"."?{digit}*)|(\.{digit}+))([Ee][+-]?{digit}+)?
identificator 			{letter}({letter}|{digit})*

%%

\n\r?				{
					LexHelper::getInstance()->cur_line++;
					LexHelper::getInstance()->cur_pos = 1;
				}
[ \t]				{
					LexHelper::getInstance()->cur_pos += yyleng;
				}
{number}			{
					LexHelper* helper = LexHelper::getInstance();
					yylval.token_node = new TokenNode();
					yylval.token_node->line = helper->cur_line;
					yylval.token_node->position = helper->cur_pos;
					yylval.token_node->text = std::string(yytext);
					yylval.token_node->token = NUMBER;
					LexHelper::getInstance()->cur_pos += yyleng;
					return NUMBER;
				}
{identificator}			{
					LexHelper::getInstance()->cur_pos += yyleng;
					return ID;
				}
;				{
					LexHelper::getInstance()->cur_pos++;
					return SEMICOL;
				}
=				{
					LexHelper::getInstance()->cur_pos++;
					return EQUAL;
				}

.				{
					std::stringstream ss;
					LexHelper* helper = LexHelper::getInstance();
					ss << "Unexpected symbol \'" << yytext << "\' at ";
					ss << helper->cur_line << ":" << helper->cur_pos;
					helper->error_list.push_back(ss.str());
					helper->cur_pos++;
				}

%%

void initScanner()
{
	LexHelper::getInstance()->reset();
}

int yywrap()
{
	const std::vector<std::string>& err = LexHelper::getInstance()->error_list;
	for (size_t i = 0; i < err.size(); ++i)
		std::cout << "[Lexical error]: " << err[i] << std::endl;
	return 1;
}
