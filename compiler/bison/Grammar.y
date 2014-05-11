%{

#include <stdio.h>
#include <SyntaxTree.h>
#include <LexHelper.h>
#include <ParserHelper.h>
#include <iostream>

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
%token<token_node> COMMA

%type<synt_node> RVALUE
%type<synt_node> VAR_DECL
%type<synt_node> VAR_SINGLE_DECL
%type<synt_node> VAR_DECL_TAIL
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

UNIT: 			VAR_DECL UNIT 
                {
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
			        $$->children.push_back($2);
                }
                |
                {
                    $$ = new SyntNode();
                    $$->text = "eps";
                }
			;
VAR_DECL: 		ID VAR_SINGLE_DECL VAR_DECL_TAIL SEMICOL
                {
                    $$ = new SyntNode();
                    $$->text = "VAR_DECL";
			        $$->children.push_back($1);
			        $$->children.push_back($2);
			        $$->children.push_back($3);
			        $$->children.push_back($4);
                }
             ;
VAR_DECL_TAIL:          COMMA VAR_SINGLE_DECL
                        {
                            $$ = new SyntNode();
                            $$->text = "VAR_DECL_TAIL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
                        }
                        |
                        {
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
			    ;

VAR_SINGLE_DECL: 		ID EQUAL RVALUE
                        {
                            $$ = new SyntNode();
                            $$->text = "VAR_SINGLE_DECL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
			                $$->children.push_back($3);
                        }
                        |
                        ID
                        {
                            $$ = new SyntNode();
                            $$->text = "VAR_SINGLE_DECL";
			                $$->children.push_back($1);
                        } 
			    ;
RVALUE: 		NUMBER 	
                {
			        $$ = new SyntNode();
                    $$->text = "RVALUE";
			        $$->children.push_back($1);
		        }
			;

%%

void yyerror(const char* message)
{
	printf("%s", message);
}
