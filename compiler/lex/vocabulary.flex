%{

#include "../bison/grammar.hpp"
#include <LexHelper.h>
#include <ParserHelper.h>
#include <SyntaxTree.h>
#include <sstream>
#include <iostream>

void initScanner();
TokenNode* registerToken(int token);

#define YY_USER_INIT initScanner()

%}

digit 				    [0-9]
letter 				    [a-zA-Z]
number				    (({digit}+"."?{digit}*)|(\.{digit}+))([Ee][+-]?{digit}+)?
identificator 			_*{letter}({letter}|{digit}|_)*
illegal_id              _*{digit}({letter}|{digit}|_)*
comment                 ("//"[^(\n\r?)]*\n)|("/*"[^"*/"]*"*/")

%%

{comment}               {
                            size_t add_line = 0;
                            for (size_t i = 0; i < yyleng; ++i)
                                if (yytext[i] == '\n')
                                    ++add_line;
					        LexHelper::getInstance()->cur_line += add_line;
					        LexHelper::getInstance()->cur_pos += yyleng;
                        }

\n\r?				    {
					        LexHelper::getInstance()->cur_line++;
					        LexHelper::getInstance()->cur_pos = 1;
				        }
[ \t]				    {
					        LexHelper::getInstance()->cur_pos += yyleng;
				        }

"return"                {
//                            std::cout << "get RETURN" << std::endl;
                            yylval.token_node = registerToken(RETURN);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return RETURN;
                        }
"break"                 {
//                            std::cout << "get BREAK" << std::endl;
                            yylval.token_node = registerToken(BREAK);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return BREAK;
                        }
"continue"              {
//                            std::cout << "get CONTINUE" << std::endl;
                            yylval.token_node = registerToken(CONTINUE);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return CONTINUE;
                        }
"if"                    {
//                            std::cout << "get IF" << std::endl;
                            yylval.token_node = registerToken(IF);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return IF;
                        }
"else"                  {
//                            std::cout << "get ELSE" << std::endl;
                            yylval.token_node = registerToken(ELSE);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return ELSE;
                        }
"for"                   {
//                            std::cout << "get FOR" << std::endl;
                            yylval.token_node = registerToken(FOR);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return FOR;
                        }
"while"                 {
//                            std::cout << "get WHILE" << std::endl;
                            yylval.token_node = registerToken(WHILE);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return WHILE;
                        }
"do"                    {
//                            std::cout << "get DO" << std::endl;
                            yylval.token_node = registerToken(DO);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return DO;
                        }
"class"                 {
//                            std::cout << "get CLASS" << std::endl;
                            yylval.token_node = registerToken(CLASS);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return CLASS;
                        }

{number}    			{
//                            std::cout << "get NUMBER" << std::endl;
                            yylval.token_node = registerToken(NUMBER);
					        LexHelper::getInstance()->cur_pos += yyleng;
					        return NUMBER;
				        }
{identificator}			{
                            std::string stext = std::string(yytext);
                            const std::set<std::string>& typeset = LexHelper::getInstance()->types;
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            if (typeset.find(stext) == typeset.end()) {
//                                std::cout << "get ID" << std::endl;
                                yylval.str_node = dynamic_cast<StringToken*>(registerToken(ID));
                				return ID;
                            } else {
//                                std::cout << "get BASIC_TYPE" << std::endl;
                                yylval.str_node = dynamic_cast<StringToken*>(registerToken(BASIC_TYPE));
                				return BASIC_TYPE;
                            }
				        }
"||"                    {
                            yylval.token_node = registerToken(LOGIC_OR_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LOGIC_OR_OP;
                        }
"++"                    {
                            yylval.token_node = registerToken(INCR_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return INCR_OP;
                        }
"--"                    {
                            yylval.token_node = registerToken(DECR_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return DECR_OP;
                        }
"&&"                    {
                            yylval.token_node = registerToken(LOGIC_AND_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LOGIC_AND_OP;
                        }
"=="                    {
                            yylval.token_node = registerToken(EQ_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return EQ_COMP_OP;
                        }
"!="                    {
                            yylval.token_node = registerToken(NE_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return NE_COMP_OP;
                        }
"<="                    {
                            yylval.token_node = registerToken(LE_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LE_COMP_OP;
                        }
">="                    {
                            yylval.token_node = registerToken(GE_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return GE_COMP_OP;
                        }
"<<"                    {
                            yylval.token_node = registerToken(LSHIFT_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LSHIFT_OP;
                        }
">>"                    {
                            yylval.token_node = registerToken(RSHIFT_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return RSHIFT_OP;
                        }
"~"                     {
                            yylval.token_node = registerToken(BW_NOT_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return BW_NOT_OP;
                        }
"!"                     {
                            yylval.token_node = registerToken(LOGIC_NOT);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LOGIC_NOT;
                        }
"*"                     {
                            yylval.token_node = registerToken(MULT_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return MULT_OP;
                        }
"."                     {
                            yylval.token_node = registerToken(DOT);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return DOT;
                        }
"/"                     {
                            yylval.token_node = registerToken(DIV_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return DIV_OP;
                        }
"%"                     {
                            yylval.token_node = registerToken(REM_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return REM_OP;
                        }

"+"                     {
                            yylval.token_node = registerToken(PLUS_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return PLUS_OP;
                        }
"-"                     {
//                            std::cout << "get MINUS_OP" << std::endl;
                            yylval.token_node = registerToken(MINUS_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return MINUS_OP;
                        }
">"                     {
                            yylval.token_node = registerToken(GT_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return GT_COMP_OP;
                        }
"<"                     {
                            yylval.token_node = registerToken(LT_COMP_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return LT_COMP_OP;
                        }
"|"                     {
                            yylval.token_node = registerToken(BW_OR_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return BW_OR_OP;
                        }
"^"                     {
                            yylval.token_node = registerToken(BW_XOR_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return BW_XOR_OP;
                        }
"&"                     {
                            yylval.token_node = registerToken(BW_AND_OP);
    					    LexHelper::getInstance()->cur_pos += yyleng;
            				return BW_AND_OP;
                        }
;				        {
//                            std::cout << "get SEMICOL" << std::endl;
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
					        LexHelper* helper = LexHelper::getInstance();
                            std::cerr << std::endl << "[Lexical error] ";
                            std::cerr << "Illegal identifier \"" << yytext;
                            std::cerr << "\" at " << helper->cur_line << ':' << helper->cur_pos << std::endl;
                            helper->cur_pos += yyleng;
                        }

")"                     {
//                            std::cout << "get RPAREN" << std::endl;
                            yylval.token_node = registerToken(RPAREN);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return RPAREN;
                        }

"("                     {
//                            std::cout << "get LPAREN" << std::endl;
                            yylval.token_node = registerToken(LPAREN);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return LPAREN;
                        }

"}"                     {
//                            std::cout << "get RBRACE" << std::endl;
                            yylval.token_node = registerToken(RBRACE);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return RBRACE;
                        }

"{"                     {
//                            std::cout << "get LBRACE" << std::endl;
                            yylval.token_node = registerToken(LBRACE);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return LBRACE;
                        }

","                     {
//                            std::cout << "get COMMA" << std::endl;
                            yylval.token_node = registerToken(COMMA);
    					    LexHelper::getInstance()->cur_pos += yyleng;
                            return COMMA;
                        }

.				        {
					        LexHelper* helper = LexHelper::getInstance();
                            std::cerr << std::endl << "[Lexical error] ";
					        std::cerr << "Unexpected symbol \'" << yytext << "\' at ";
					        std::cerr << helper->cur_line << ":" << helper->cur_pos << std::endl;
					        helper->cur_pos++;
				        }

%%

void initScanner() {
	LexHelper::getInstance()->reset();
}

TokenNode* registerToken(int token) {
    TokenNode* token_node;
    StringToken* str_node;
    if (token == ID || token == BASIC_TYPE) {
        str_node = new StringToken();
        token_node = static_cast<TokenNode*>(str_node);
    } else {
        token_node = new TokenNode();
        str_node = NULL;
    }
    LexHelper::setToken(token_node);
    token_node->text = std::string(yytext);
    token_node->token = token;
    LexHelper::getInstance()->cur_token = token;
    if (str_node != NULL)
        str_node->str = std::string(yytext);
    return token_node;
}

int yywrap()
{
	return 1;
}
