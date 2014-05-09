%{

#include <stdio.h>
#include <SyntaxTree.h>
#include <LexHelper.h>
#include <ParserHelper.h>

extern int yylex();
void yyerror(const char* message);

%}

%union {
	class TokenNode* token_node;
	class SyntNode* synt_node;		
}

%token<token_node> NUMBER 
%token<token_node> SEMICOL
%token<token_node> ID 
%token<token_node> EQUAL

%type<synt_node> RVALUE
%type<synt_node> VAR_DEFIN
%type<synt_node> VAR_INFO
%type<synt_node> UNIT
%type<synt_node> SUPER_UNIT

%start SUPER_UNIT

%%

SUPER_UNIT:		UNIT
                {
                    ParserHelper* helper = ParserHelper::getInstance();
                    helper->ast = $1;
                }
			;

UNIT: 			VAR_INFO UNIT 
                {
                    $$ = new SyntNode();
			        $$->children.push_back($1);
			        $$->children.push_back($2);
                }
                |
                {
                    $$ = new SyntNode();
                }
			;
VAR_INFO: 		ID ID SEMICOL
                {
                    $$ = new SyntNode();
			        $$->children.push_back($1);
			        $$->children.push_back($2);
			        $$->children.push_back($3);
                }
                |
			    ID ID VAR_DEFIN
                {
                    $$ = new SyntNode();
			        $$->children.push_back($1);
			        $$->children.push_back($2);
			        $$->children.push_back($3);
                }

			;

VAR_DEFIN: 		EQUAL RVALUE SEMICOL
                {
                    $$ = new SyntNode();
			        $$->children.push_back($1);
			        $$->children.push_back($2);
			        $$->children.push_back($3);
                }
			;
RVALUE: 		NUMBER 	
                { 
			        $$ = new SyntNode();
			        $$->children.push_back($1);
		        }
			;

%%

void yyerror(const char* message)
{
	printf("%s", message);
}
