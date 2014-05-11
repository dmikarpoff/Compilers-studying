%{

#include "../bison/grammar.hpp"
#include <LexHelper.h>
#include <SyntaxTree.h>
#include <sstream>
#include <iostream>

void initScanner();
TokenNode* registerToken(int token);

#define YY_USER_INIT initScanner()

%}

digit 				    [0-9]
letter 				    [a-zA-Z]
number				    (([-+]?{digit}+"."?{digit}*)|(\.{digit}+))([Ee][+-]?{digit}+)?
identificator 			_*{letter}({letter}|{digit}|_)*
illegal_id              _*{digit}({letter}|{digit}|_)*

%%

\n\r?				    {
					        LexHelper::getInstance()->cur_line++;
					        LexHelper::getInstance()->cur_pos = 1;
				        }
[ \t]				    {
					        LexHelper::getInstance()->cur_pos += yyleng;
				        }
{number}    			{
                            yylval.token_node = registerToken(NUMBER);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return NUMBER;
				        }
{identificator}			{
                            yylval.token_node = registerToken(ID);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return ID;
				        }
;				        {
                            yylval.token_node = registerToken(SEMICOL);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return SEMICOL;
				        }
=				        {
                            yylval.token_node = registerToken(EQUAL);
    					    LexHelper::getInstance()->cur_pos += yyleng;
        					return EQUAL;
        				}

{illegal_id}            {
                            std::stringstream ss;
					        LexHelper* helper = LexHelper::getInstance();
                            ss << "Illegal identifier \"" << yytext;
                            ss << "\" at " << helper->cur_line << ':' << helper->cur_pos;
                            helper->error_list.push_back(ss.str());
                            helper->cur_pos += yyleng;
                        }

.				        {
					        std::stringstream ss;
					        LexHelper* helper = LexHelper::getInstance();
					        ss << "Unexpected symbol \'" << yytext << "\' at ";
					        ss << helper->cur_line << ":" << helper->cur_pos;
					        helper->error_list.push_back(ss.str());
					        helper->cur_pos++;
				        }

%%

void initScanner() {
	LexHelper::getInstance()->reset();
}

TokenNode* registerToken(int token) {
    TokenNode* token_node = new TokenNode();
    LexHelper::setToken(token_node);
    token_node->text = std::string(yytext);
    token_node->token = token;
}

int yywrap()
{
	const std::vector<std::string>& err = LexHelper::getInstance()->error_list;
	for (size_t i = 0; i < err.size(); ++i)
		std::cout << "[Lexical error]: " << err[i] << std::endl;
	return 1;
}
