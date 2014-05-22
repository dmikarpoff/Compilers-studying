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

%token<token_node> NUMBER IF ELSE
%token<token_node> SEMICOL
%token<token_node> ID TYPE
%token<token_node> EQUAL
%token<token_node> COMMA LPAREN RPAREN LBRACE RBRACE
%token<token_node> LOGIC_OR_OP LOGIC_AND_OP BW_OR_OP
%token<token_node> BW_XOR_OP BW_AND_OP EQ_COMP_OP NE_COMP_OP
%token<token_node> LE_COMP_OP LT_COMP_OP GT_COMP_OP GE_COMP_OP
%token<token_node> LSHIFT_OP RSHIFT_OP PLUS_OP MINUS_OP
%token<token_node> DIV_OP MULT_OP REM_OP BW_NOT_OP LOGIC_NOT
%token<token_node> RETURN

%type<synt_node> RVALUE SIGNATURE ARG_LIST ARG_LIST_TAIL
%type<synt_node> VAR_DECL FUNC_DECL ARG_DECL STATEMENT_LIST
%type<synt_node> VAR_SINGLE_DECL
%type<synt_node> VAR_DECL_TAIL
%type<synt_node> UNIT BLOCK
%type<synt_node> SUPER_UNIT
%type<synt_node> ELSESTM BOTHSTM STATEMENT
%type<synt_node> LOGIC_OR_EXPR LOGIC_AND_EXPR BW_OR_EXPR
%type<synt_node> BW_XOR_EXPR BW_AND_EXPR EQ_EXPR ORD_EXPR
%type<synt_node> SHIFT_EXPR SUM_EXPR MULT_EXPR CAST_EXPR
%type<synt_node> SIMPLE_EXPR INSTRUCTION SINGLE_ST

%start SUPER_UNIT

%%

SUPER_UNIT:		UNIT
                {
                    std::cout << "SUPER_UNIT<-UNIT" << std::endl;
                    ParserHelper* helper = ParserHelper::getInstance();
                    helper->ast = $1;
                }
			;

UNIT: 			VAR_DECL UNIT 
                {
                    std::cout << "UNIT<-VAR_DECL UNIT" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
			        $$->children.push_back($2);
                }
                |
                FUNC_DECL UNIT
                {
                    std::cout << "UNIT<-FUNC_DECL UNIT" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
			        $$->children.push_back($2);
                }    
                |
                {
                    std::cout << "UNIT<-eps" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "eps";
                }
            ;
VAR_DECL: 		TYPE VAR_SINGLE_DECL VAR_DECL_TAIL SEMICOL
                {
                    std::cout << "VAR_DECL<-TYPE VAR_SINGLE_DECL VAR_DECL_TAIL SEMICOL" << std::endl;
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
                            std::cout << "VAR_DECL_TAIL<-COMMA VAR_SINGLE_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "VAR_DECL_TAIL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "VAR_DECL_TAIL<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
			    ;

VAR_SINGLE_DECL: 		ID EQUAL RVALUE
                        {
                            std::cout << "VAR_SINGLE_DECL<-ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "VAR_SINGLE_DECL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
			                $$->children.push_back($3);
                        }
                        |
                        ID
                        {
                            std::cout << "VAR_SINGLE_DECL<-ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "VAR_SINGLE_DECL";
			                $$->children.push_back($1);
                        }
			    ;

FUNC_DECL:              SIGNATURE SEMICOL
                        {
                            std::cout << "FUNC_DECL <- SIGNATURE SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FUNC_DECL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
                        }
                        |
                        SIGNATURE BLOCK
                        {
                            std::cout << "FUNC_DECL <- SIGNATURE BLOCK" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FUNC_DECL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
                        }

                ;

SIGNATURE:              TYPE ID LPAREN ARG_LIST RPAREN
                        {
                            std::cout << "SIGNATURE<-TYPE ID LPAREN ARG_LIST RPAREN" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIGNATURE";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
			                $$->children.push_back($3);
			                $$->children.push_back($4);
			                $$->children.push_back($5);
                        }
                ;

ARG_DECL:               TYPE
                        {
                            std::cout << "ARG_DECL<-TYPE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
                        }
                        |
                        TYPE ID
                        {
                            std::cout << "ARG_DECL<-TYPE ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        TYPE ID EQUAL NUMBER
                        {
                            std::cout << "ARG_DECL<-TYPE ID EQUAL NUMBER" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
                        }
                   ;

ARG_LIST:               ARG_DECL ARG_LIST_TAIL
                        {
                            std::cout << "ARG_LIST<-ARG_DECL ARG_LIST_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_LIST";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "ARG_LIST<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

ARG_LIST_TAIL:          COMMA ARG_DECL ARG_LIST_TAIL
                        {
                            std::cout << "ARG_LIST_TAIL<-COMMA ARG_DECL ARG_LIST_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_LIST_TAIL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        {
                            std::cout << "ARG_LIST_TAIL<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;               

RVALUE:          		ID EQUAL RVALUE
                        {
                            std::cout << "RVALUE<-ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "RVALUE";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        LOGIC_OR_EXPR
                        {
                            std::cout << "RVALUE<-LOGIC_OR_EXPR" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "RVALUE";
	                        $$->children.push_back($1);
                        }
		        ;

BLOCK:                  LBRACE STATEMENT_LIST RBRACE
                        {
                            std::cout << "BLOCK<-LBRACE STATEMENT_LIST RBRACE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "BLOCK";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                ;

STATEMENT_LIST:         SINGLE_ST STATEMENT_LIST
                        {
                            std::cout << "STATEMENT_LIST<-SINGLE_ST STATEMENT_LIST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "STATEMENT_LIST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "STATEMENT_LIST<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";                            
                        }
                ;

SINGLE_ST:              ELSESTM
                        {
                            std::cout << "SINGLE_ST<-ELSESTM" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        BOTHSTM
                        {
                            std::cout << "SINGLE_ST<-BOTHSTM" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                ;
              
BOTHSTM:                IF LPAREN RVALUE RPAREN BOTHSTM ELSE BOTHSTM
                        {
                            std::cout << "BOTHSTM<-IF LPAREN RVALUE RPAREN BOTHSTM ELSE BOTHSTM" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "BOTHSTM";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
	                        $$->children.push_back($6);
	                        $$->children.push_back($7);
                        }                        
                        |
                        STATEMENT           
                        {
                            std::cout << "BOTHSTM<-STATEMENT" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "BOTHSTM";
	                        $$->children.push_back($1);
                        }                                                             
                ;

ELSESTM:                IF LPAREN RVALUE RPAREN SINGLE_ST
                        {
                            std::cout << "ELSESTM<-IF LPAREN RVALUE RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ELSESTM";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
                        }
                        |
                        IF LPAREN RVALUE RPAREN BOTHSTM ELSE ELSESTM
                        {
                            std::cout << "ELSESTM<-IF LPAREN RVALUE RPAREN BOTHSTM ELSE ELSESTM" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ELSESTM";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
	                        $$->children.push_back($6);
	                        $$->children.push_back($7);
                        }
                ;

STATEMENT:              INSTRUCTION SEMICOL
                        {
                            std::cout << "STATEMENT<-INSTRUCTION SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "STATEMENT";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        BLOCK
                        {
                            std::cout << "STATEMENT<-BLOCK" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "STATEMENT";
	                        $$->children.push_back($1);
                        }
                        |
                        VAR_DECL
                        {
                            std::cout << "STATEMENT<-VAR_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "STATEMENT";
	                        $$->children.push_back($1);
                        }
                ;
                        

INSTRUCTION:            ID EQUAL RVALUE
                        {
                            std::cout << "INSTRUCTION<-ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "INSTRUCTION";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        RETURN RVALUE
                        {
                            std::cout << "INSTRUCTION<-RETURN RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "INSTRUCTION";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "INSTRUCTION<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

LOGIC_OR_EXPR:          LOGIC_OR_EXPR LOGIC_OR_OP LOGIC_AND_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "LOGIC_OR_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                            $$->children.push_back($3);
                        }
                        |
                        LOGIC_AND_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "LOGIC_OR_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

LOGIC_AND_EXPR:         LOGIC_AND_EXPR LOGIC_AND_OP BW_OR_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "LOGIC_AND_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        BW_OR_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "LOGIC_AND_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

BW_OR_EXPR:             BW_OR_EXPR BW_OR_OP BW_XOR_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_OR_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        BW_XOR_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_OR_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

BW_XOR_EXPR:            BW_XOR_EXPR BW_XOR_OP BW_AND_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_XOR_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        BW_AND_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_XOR_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

BW_AND_EXPR:            BW_AND_EXPR BW_AND_OP EQ_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_AND_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        EQ_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "BW_AND_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

EQ_EXPR:                EQ_EXPR EQ_COMP_OP ORD_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "EQ_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        EQ_EXPR NE_COMP_OP ORD_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "EQ_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        ORD_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "EQ_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

ORD_EXPR:               ORD_EXPR LT_COMP_OP SHIFT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "ORD_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        ORD_EXPR LE_COMP_OP SHIFT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "ORD_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        ORD_EXPR GT_COMP_OP SHIFT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "ORD_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        ORD_EXPR GE_COMP_OP SHIFT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "ORD_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        SHIFT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "ORD_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

SHIFT_EXPR:             SHIFT_EXPR LSHIFT_OP SUM_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SHIFT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        SHIFT_EXPR RSHIFT_OP SUM_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SHIFT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        SUM_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SHIFT_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

SUM_EXPR:               SUM_EXPR PLUS_OP MULT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SUM_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        SUM_EXPR MINUS_OP MULT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SUM_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        MULT_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "SUM_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

MULT_EXPR:              MULT_EXPR DIV_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        MULT_EXPR REM_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        MULT_EXPR MULT_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);

                        }
                        |
                        CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

CAST_EXPR:              LPAREN TYPE RPAREN SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                            $$->children.push_back($4);
                        }
                        |
                        PLUS_OP SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        MINUS_OP SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        LOGIC_NOT SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        BW_NOT_OP SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        SIMPLE_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                        }
                ;

SIMPLE_EXPR:            LPAREN RVALUE RPAREN
                        {
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                        }
                        |
                        ID
                        {
                            std::cout << "SIMPLE_EXPR <- ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_EXPR";
                            $$->children.push_back($1);
                        }
                        |
                        NUMBER
                        {
                            std::cout << "SIMPLE_EXPR <- NUMBER" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_EXPR";
                            $$->children.push_back($1);
                        }
                ;

%%

void yyerror(const char* message)
{
	printf("[Syntax error] %s\n", message);
}
