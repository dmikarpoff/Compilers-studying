%{

#include <stdio.h>
#include <SyntaxTree.h>
#include <LexHelper.h>
#include <ParserHelper.h>
#include <iostream>

#define YYERROR_VERBOSE 5

extern int yylex();
void yyerror(const char* message);

%}

%union {
	class TokenNode* token_node;
	class SyntNode* synt_node;		
    class StringToken* str_node;
    class IDNode* idsynt_node;
}

%token<token_node> NUMBER IF ELSE BREAK CONTINUE
%token<token_node> SEMICOL
%token<str_node>   ID BASIC_TYPE
%token<token_node> EQUAL
%token<token_node> COMMA LPAREN RPAREN LBRACE RBRACE
%token<token_node> LOGIC_OR_OP LOGIC_AND_OP BW_OR_OP
%token<token_node> BW_XOR_OP BW_AND_OP EQ_COMP_OP NE_COMP_OP
%token<token_node> LE_COMP_OP LT_COMP_OP GT_COMP_OP GE_COMP_OP
%token<token_node> LSHIFT_OP RSHIFT_OP PLUS_OP MINUS_OP
%token<token_node> DIV_OP MULT_OP REM_OP BW_NOT_OP LOGIC_NOT
%token<token_node> RETURN FOR INCR_OP DECR_OP DO WHILE
%token<token_node> CLASS DOT

%type<synt_node> RVALUE SIGNATURE ARG_LIST ARG_LIST_TAIL LVALUE LVAL_ACCTAIL
%type<synt_node> VAR_DECL FUNC_DECL ARG_DECL STATEMENT_LIST
%type<synt_node> VAR_SINGLE_DECL TYPE
%type<synt_node> VAR_DECL_TAIL
%type<synt_node> UNIT BLOCK
%type<synt_node> SUPER_UNIT
%type<synt_node> CONDITION_ST LOOP_ST SIMPLE_ST
%type<synt_node> LOGIC_OR_EXPR LOGIC_AND_EXPR BW_OR_EXPR
%type<synt_node> BW_XOR_EXPR BW_AND_EXPR EQ_EXPR ORD_EXPR
%type<synt_node> SHIFT_EXPR SUM_EXPR MULT_EXPR CAST_EXPR
%type<synt_node> SIMPLE_EXPR SINGLE_ST
%type<synt_node> FUNC_CALL PARAM_LIST PARAM_LIST_TAIL
%type<synt_node> FOR_INIT FOR_INIT_TAIL FOR_COND FOR_STEP FOR_STEP_TAIL
%type<synt_node> INCR_EXPR
%type<synt_node> CLASS_ENTRY
%type<synt_node> ELEM_EXPR
%type<synt_node> MEMB_ACCESS CLASS_DEF

%start SUPER_UNIT

%%

TYPE:           BASIC_TYPE
                {
                    std::cout << "TYPE<-BASIC_TYPE" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "TYPE";
			        $$->children.push_back($1);
                }
                |
                ID
                {
                    std::cout << "TYPE<-ID" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "TYPE";
			        $$->children.push_back($1);
                }
            ;

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
                CLASS_DEF UNIT 
                {
                    std::cout << "UNIT<-CLASS_DEF UNIT" << std::endl;
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


CLASS_DEF:   CLASS ID LBRACE CLASS_ENTRY RBRACE SEMICOL
                {
                    $$ = new SyntNode();
                    $$->text = "CLASS_DEF";
                    std::cout << "CLASS_DEF<-CLASS ID LBRACE CLASS_ENTRY RBRACE SEMICOL" << std::endl;
                    $$->children.push_back($1);
			        $$->children.push_back($2);
			        $$->children.push_back($3);
			        $$->children.push_back($4);
			        $$->children.push_back($5);
			        $$->children.push_back($6);
                }
            ;

CLASS_ENTRY:        VAR_DECL CLASS_ENTRY
                    {
                        std::cout << "CLASS_ENTRY<-VAR_DECL CLASS_ENTRY" << std::endl;
                        $$ = new SyntNode();
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                        $$->text = "CLASS_ENTRY";
                    }
                    |
                    FUNC_DECL CLASS_ENTRY
                    {
                        std::cout << "CLASS_ENTRY<-FUNC_DECL CLASS_ENTRY" << std::endl;
                        $$ = new SyntNode();
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                        $$->text = "DECDEF_CLASS_BLOCK";
                    }
                    |
                    {
                        std::cout << "CLASS_ENTRY<-eps" << std::endl;
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

FUNC_DECL:              SIGNATURE BLOCK
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


ARG_LIST:               ARG_LIST_TAIL
                        {
                            std::cout << "ARG_LIST<-ARG_LIST_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_LIST";
                            $$->children.push_back($1);
                        }
                        |
                        {
                            std::cout << "ARG_LIST<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

ARG_LIST_TAIL:          ARG_LIST_TAIL COMMA ARG_DECL
                        {
                            std::cout << "ARG_LIST_TAIL<-ARG_LIST_TAIL COMMA ARG_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_LIST_TAIL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        ARG_DECL
                        {
                            std::cout << "ARG_LIST_TAIL<-ARG_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_LIST_TAIL";
	                        $$->children.push_back($1);
                        }
                ;

ARG_DECL:               TYPE ID
                        {
                            std::cout << "ARG_DECL<-TYPE ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        TYPE ID EQUAL RVALUE
                        {
                            std::cout << "ARG_DECL<-TYPE ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
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

SINGLE_ST:              CONDITION_ST
                        {
                            std::cout << "SINGLE_ST<-CONDITION_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        LOOP_ST
                        {
                            std::cout << "SINGLE_ST<-LOOP_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        SIMPLE_ST SEMICOL
                        {
                            std::cout << "SINGLE_ST<-SIMPLE_ST SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        BLOCK
                        {
                            std::cout << "SINGLE_ST<-BLOCK" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        VAR_DECL
                        {
                            std::cout << "SINGLE_ST<-VAR_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SINGLE_ST";
	                        $$->children.push_back($1);
                        }
                ;
CONDITION_ST:           IF LPAREN RVALUE RPAREN SINGLE_ST ELSE SINGLE_ST
                        {
                            std::cout << "CONDITION_ST<-IF LPAREN RVALUE RPAREN SINGLE_ST ELSE SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "CONDITION_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
	                        $$->children.push_back($6);
	                        $$->children.push_back($7);
                        }
                        |
                        IF LPAREN RVALUE RPAREN SINGLE_ST
                        {
                            std::cout << "CONDITION_ST<-IF LPAREN RVALUE RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "CONDITION_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
                        }
                ;

LOOP_ST:                FOR LPAREN FOR_INIT FOR_COND FOR_STEP RPAREN SINGLE_ST
                        {
                            std::cout << "LOOP_ST<-FOR LPAREN FOR_INIT FOR_COND FOR_STEP RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "LOOP_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
	                        $$->children.push_back($6);
	                        $$->children.push_back($7);
                        }
                        |
                        WHILE LPAREN RVALUE RPAREN SINGLE_ST
                        {
                            std::cout << "LOOP_ST<-WHILE LPAREN RVALUE RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "LOOP_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
                        }
                        |
                        DO BLOCK WHILE LPAREN RVALUE RPAREN SEMICOL
                        {
                            std::cout << "LOOP_ST<-DO BLOCK WHILE LPAREN RVALUE RPAREN SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "LOOP_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($4);
	                        $$->children.push_back($5);
	                        $$->children.push_back($6);
	                        $$->children.push_back($7);
                        }
                ;

SIMPLE_ST:              RVALUE
                        {
                            std::cout << "SIMPLE_ST<-RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        RETURN RVALUE
                        {
                            std::cout << "SIMPLE_ST<-RETURN RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_ST";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        BREAK
                        {
                            std::cout << "SIMPLE_ST<-BREAK" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "SIMPLE_ST";
	                        $$->children.push_back($1);
                        }
                        |
                        CONTINUE
                        {
                            std::cout << "INSTRUCTION<-CONTINUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "INSTRUCTION";
	                        $$->children.push_back($1);
                        }
                        |
                        {
                            std::cout << "INSTRUCTION<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

FOR_INIT:               VAR_DECL
                        {
                            std::cout << "FOR_INIT<-VAR_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT";
	                        $$->children.push_back($1);
                        }
                        |
                        RVALUE FOR_INIT_TAIL
                        {
                            std::cout << "FOR_INIT<-RVALUE FOR_INIT_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        SEMICOL
                        {
                            std::cout << "FOR_INIT<-SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT";
	                        $$->children.push_back($1);
                        }
                ;

FOR_INIT_TAIL:          COMMA RVALUE FOR_INIT_TAIL
                        {
                            std::cout << "FOR_INIT_TAIL<-COMMA RVALUE FOR_INIT_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT_TAIL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        SEMICOL
                        {
                            std::cout << "FOR_INIT_TAIL<-SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT_TAIL";
	                        $$->children.push_back($1);
                        }
                ;

FOR_COND:               RVALUE SEMICOL
                        {
                            std::cout << "FOR_COND<-RVALUE SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_COND";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                ;

FOR_STEP:               RVALUE FOR_STEP_TAIL
                        {
                            std::cout << "FOR_STEP<-RVALUE FOR_STEP_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_STEP";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "FOR_STEP<-eps" << std::endl;
                            $$ = new SyntNode();    
                            $$->text = "eps";
                        }
                ;

FOR_STEP_TAIL:          COMMA RVALUE FOR_STEP_TAIL
                        {
                            std::cout << "FOR_STEP_TAIL<-COMMA RVALUE FOR_STEP_TAIL" << std::endl;
                            $$ = new SyntNode();    
                            $$->text = "FOR_STEP_TAIL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        {
                            std::cout << "FOR_STEP_TAIL<-eps" << std::endl;
                            $$ = new SyntNode();    
                            $$->text = "eps";
                        }
                ;                                               

RVALUE:          		LVALUE EQUAL RVALUE
                        {
                            std::cout << "RVALUE<-LVALUE EQUAL RVALUE" << std::endl;
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
                            std::cout << "SUM_EXPR<-MULT_EXPR" << std::endl;
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
                            std::cout << "MULT_EXPR<-MULT_EXPR MULT_OP CAST_EXPR" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        CAST_EXPR
                        {
                            std::cout << "MULT_EXPR<-CAST_EXPR" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "MULT_EXPR";
	                        $$->children.push_back($1);
                        }
                ;

CAST_EXPR:              LPAREN BASIC_TYPE RPAREN CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                            $$->children.push_back($4);
                        }
                        |
                        PLUS_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        MINUS_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        LOGIC_NOT CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        BW_NOT_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        INCR_EXPR
                        {
                            std::cout << "CAST_EXPR<-INCR_EXPR" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                        }
                        |
                        INCR_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        DECR_OP CAST_EXPR
                        {
                            $$ = new SyntNode();
                            $$->text = "CAST_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                ;

INCR_EXPR:              INCR_EXPR INCR_OP
                        {
                            $$ = new SyntNode();
                            $$->text = "INCR_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        INCR_EXPR DECR_OP
                        {
                            $$ = new SyntNode();
                            $$->text = "INCR_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        SIMPLE_EXPR
                        {
                            std::cout << "INCR_EXPR<-SIMPLE_EXPR" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "INCR_EXPR";
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
                        ELEM_EXPR
                        {
                            std::cout << "SIMPLE_EXPR <- ELEM_EXPR" << std::endl;
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

FUNC_CALL:              ID LPAREN PARAM_LIST RPAREN
                        {
                            std::cout << "FUNC_CALL<-ID LPAREN PARAM_LIST RPAREN" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FUNC_CALL";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                            $$->children.push_back($4);
                        }
                ;

PARAM_LIST:             RVALUE PARAM_LIST_TAIL
                        {
                            std::cout << "PARAM_LIST<-RVALUE PARAM_LIST_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "PARAM_LIST";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        {
                            std::cout << "PARAM_LIST<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;
PARAM_LIST_TAIL:        COMMA RVALUE PARAM_LIST_TAIL
                        {
                            std::cout << "PARAM_LIST_TAIL<-COMMA RVALUE PARAM_LIST_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "PARAM_LIST_TAIL";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                        }
                        |
                        {
                            std::cout << "PARAM_LIST_TAIL<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

ELEM_EXPR:              ID MEMB_ACCESS
                        {
                            std::cout << "ELEM_EXPR<-ID MEMB_ACCESS" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ELEM_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                        |
                        FUNC_CALL MEMB_ACCESS
                        {
                            std::cout << "ELEM_EXPR<-FUNC_CALL MEMB_ACCESS" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ELEM_EXPR";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
                ;

MEMB_ACCESS:            DOT ID MEMB_ACCESS
                        {
                            std::cout << "MEMB_ACCESS<-DOT ID MEMB_ACCESS" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "MEMB_ACCESS";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                        }
                        |
                        DOT FUNC_CALL MEMB_ACCESS
                        {
                            std::cout << "MEMB_ACCESS<-DOT METHOD_CALL MEMB_ACCESS" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "MEMB_ACCESS";
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                            $$->children.push_back($3);
                        }
                        |    
                        {
                            std::cout << "MEMB_ACCESS<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "eps";
                        }
                ;

LVALUE:             ID LVAL_ACCTAIL
                    {
                        std::cout << "LVALUE<-LONG_NAME LVAL_ACCTAIL" << std::endl;
                        $$ = new SyntNode();
                        $$->text = "LVALUE";
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                    }
                ;

LVAL_ACCTAIL:       DOT ID LVAL_ACCTAIL
                    {
                        std::cout << "LVAL_ACCTAIL<-DOT ID LVAL_ACCTAIL" << std::endl;
                        $$ = new SyntNode();
                        $$->text = "LVAL_ACCTAIL";
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                        $$->children.push_back($3);
                    }
                    |
                    {
                        std::cout << "LVAL_ACCTAIL<-eps" << std::endl;
                        $$ = new SyntNode();
                        $$->text = "eps";
                    }
                ;

%%

void yyerror(const char* message)
{
	printf("[Syntax error] %s\n", message);
}
