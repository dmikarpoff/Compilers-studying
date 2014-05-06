%{

#include <stdio.h>
#include <SyntaxTree.h>
#include <LexHelper.h>

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

%start SUPER_UNIT

%%

SUPER_UNIT:		UNIT
			;

UNIT: 			VAR_INFO UNIT |
			;
VAR_INFO: 		ID ID VAR_DECL |
			    ID ID VAR_DEFIN
			;
VAR_DECL: 		SEMICOL
			;
VAR_DEFIN: 		EQUAL RVALUE SEMICOL
			;
RVALUE: 		NUMBER 	{ 
					$$ = new SyntNode();
					$$->children.push_back($1)
				}
			;

%%

void yyerror(const char* message)
{
	printf("%s", message);
}
