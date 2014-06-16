%{

#include <stdio.h>
#include <SyntaxTree.h>
#include <LexHelper.h>
#include <ParserHelper.h>
#include <iostream>
#include <sstream>

#define YYERROR_VERBOSE 5

extern int yylex();
void yyerror(const char* message);

%}

%union {
	class TokenNode* token_node;
	class SyntNode* synt_node;		
    class SuperNode* super_node;
    class StringToken* str_node;
    class IDNode* idsynt_node;
}

%token<token_node> NUMBER IF ELSE BREAK CONTINUE
%token<token_node> SEMICOL
%token<token_node> ID BASIC_TYPE
%token<token_node> EQUAL
%token<token_node> COMMA LPAREN RPAREN LBRACE RBRACE
%token<token_node> LOGIC_OR_OP LOGIC_AND_OP BW_OR_OP
%token<token_node> BW_XOR_OP BW_AND_OP EQ_COMP_OP NE_COMP_OP
%token<token_node> LE_COMP_OP LT_COMP_OP GT_COMP_OP GE_COMP_OP
%token<token_node> LSHIFT_OP RSHIFT_OP PLUS_OP MINUS_OP
%token<token_node> DIV_OP MULT_OP REM_OP BW_NOT_OP LOGIC_NOT
%token<token_node> RETURN FOR INCR_OP DECR_OP DO WHILE
%token<token_node> CLASS DOT

%type<super_node> SHIFT_EXPR LVALUE MEMB_ACCESS ELEM_EXPR
%type<super_node> ARG_LIST TYPE BLOCK
%type<super_node> ARG_LIST_TAIL SINGLE_ST SIMPLE_ST RVALUE
%type<super_node> LOGIC_OR_EXPR LOGIC_AND_EXPR BW_OR_EXPR
%type<super_node> BW_XOR_EXPR BW_AND_EXPR EQ_EXPR ORD_EXPR
%type<super_node> SUM_EXPR MULT_EXPR CAST_EXPR INCR_EXPR SIMPLE_EXPR
%type<super_node> FUNC_CALL PARAM_LIST PARAM_LIST_TAIL METHOD_CALL CONDITION
%type<synt_node> SIGNATURE FOR_ENTRY
%type<synt_node> VAR_DECL FUNC_DECL ARG_DECL STATEMENT_LIST
%type<synt_node> VAR_SINGLE_DECL
%type<synt_node> VAR_DECL_TAIL
%type<synt_node> UNIT
%type<synt_node> SUPER_UNIT CLASS_DEF
%type<synt_node> CONDITION_ST LOOP_ST
%type<synt_node> FOR_INIT FOR_INIT_TAIL FOR_COND FOR_STEP FOR_STEP_TAIL
%type<synt_node> CLASS_ENTRY

%start SUPER_UNIT

%%

TYPE:           BASIC_TYPE
                {
//                    std::cout << "TYPE<-BASIC_TYPE" << std::endl;
                    $$ = $1;
                }
                |
                ID
                {
//                    std::cout << "TYPE<-ID" << std::endl;
                    $$ = $1;
                }
            ;

SUPER_UNIT:		UNIT
                {
//                    std::cout << "SUPER_UNIT<-UNIT" << std::endl;
                    ParserHelper* helper = ParserHelper::getInstance();
                    helper->ast = $1;
                }
			;

UNIT: 			VAR_DECL UNIT 
                {
//                    std::cout << "UNIT<-VAR_DECL UNIT" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
                    if ($2 != NULL)
    			        $$->children.push_back($2);
                }
                |
                FUNC_DECL UNIT
                {
//                    std::cout << "UNIT<-FUNC_DECL UNIT" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
                    if ($2 != NULL)
    			        $$->children.push_back($2);
                }
                |
                CLASS_DEF UNIT 
                {
//                    std::cout << "UNIT<-CLASS_DEF UNIT" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "UNIT";
			        $$->children.push_back($1);
                    if ($2 != NULL)
    			        $$->children.push_back($2);
                }    
                |
                {
//                    std::cout << "UNIT<-eps" << std::endl;
                    $$ = NULL;
                }
               |
               error RBRACE UNIT
               {
                    $$ = new SyntNode();
                    $$->text = "UNIT";
                    SyntNode* node = new SyntNode();
                    node->text = "error";
                    $$->children.push_back(node);
                    if ($3 != NULL)
                        $$->children.push_back($3);
               }
            ;


CLASS_DEF:      CLASS ID LBRACE CLASS_ENTRY RBRACE SEMICOL
                {
                    $$ = new SyntNode();
                    $$->text = "class";

//                    std::cout << "CLASS_DEF<-CLASS ID LBRACE CLASS_ENTRY RBRACE SEMICOL" << std::endl;
			        $$->children.push_back($2);
                    if ($4 != NULL)
    			        $$->children.push_back($4);
                }
                |
                CLASS ID LBRACE error RBRACE SEMICOL
                {
//                    std::cout << "class_error" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "class_error";
                }
            ;

CLASS_ENTRY:        VAR_DECL CLASS_ENTRY
                    {
//                        std::cout << "CLASS_ENTRY<-VAR_DECL CLASS_ENTRY" << std::endl;
                        $$ = new SyntNode();
                        $$->children.push_back($1);
                        if ($2 != NULL)
                            $$->children.push_back($2);
                        $$->text = "in_class";
                    }
                    |
                    FUNC_DECL CLASS_ENTRY
                    {
//                        std::cout << "CLASS_ENTRY<-FUNC_DECL CLASS_ENTRY" << std::endl;
                        $$ = new SyntNode();
                        $$->children.push_back($1);
                        if ($2 != NULL)
                            $$->children.push_back($2);
                        $$->text = "in_class";
                    }
                    |
                    error RBRACE CLASS_ENTRY
                    {

                        $$ = new SyntNode();
                        $$->text = "error";
                        if ($3 != NULL)
                            $$->children.push_back($3);
                    }
                    |
                    {
//                        std::cout << "CLASS_ENTRY<-eps" << std::endl;
                        $$ = NULL;
                    }
            ;


VAR_DECL: 		TYPE VAR_SINGLE_DECL VAR_DECL_TAIL SEMICOL
                {
//                    std::cout << "VAR_DECL<-TYPE VAR_SINGLE_DECL VAR_DECL_TAIL SEMICOL" << std::endl;
                    $$ = new SyntNode();
                    $$->text = "declare";
			        $$->children.push_back($1);
			        $$->children.push_back($2);
                    if ($3 != NULL)
    			        $$->children.push_back($3);
                }
                | 
                error VAR_DECL_TAIL SEMICOL
                {
                    $$ = new SyntNode();
                    $$->text = "declare_error";
                }
             ;

VAR_DECL_TAIL:          COMMA VAR_SINGLE_DECL VAR_DECL_TAIL
                        {
//                            std::cout << "VAR_DECL_TAIL<-COMMA VAR_SINGLE_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "decl_list";
			                $$->children.push_back($2);
                            if ($3 != NULL)
    			                $$->children.push_back($3);
                        }
                        |
                        {
                            $$ = NULL;
                        }
			    ;

VAR_SINGLE_DECL: 		ID EQUAL RVALUE
                        {
//                            std::cout << "VAR_SINGLE_DECL<-ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "var_decl";
			                $$->children.push_back($1);
			                $$->children.push_back($3);
                        }
                        |
                        ID
                        {
//                            std::cout << "VAR_SINGLE_DECL<-ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "var_decl";
			                $$->children.push_back($1);
                        }
                        |
                        ID EQUAL error
                        {
                            $$ = new SyntNode();
                            $$->text = "var_single_error";
                        }
			    ;

FUNC_DECL:              SIGNATURE BLOCK
                        {
//                            std::cout << "FUNC_DECL <- SIGNATURE BLOCK" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FUNC_DECL";
			                $$->children.push_back($1);
			                $$->children.push_back($2);
                        }
                        |
                        SIGNATURE error RBRACE
                        {
                            $$ = new SyntNode();
                            $$->text = "sign_error";
                        }
                        |
                        TYPE LPAREN error RBRACE
                        {
                            $$ = new SyntNode();
                            $$->text = "sign_error";
                        }
                ;

SIGNATURE:          TYPE ID LPAREN ARG_LIST RPAREN
                    {
//                      std::cout << "SIGNATURE<-TYPE ID LPAREN ARG_LIST RPAREN" << std::endl;
                        $$ = new SyntNode();
                        $$->text = "SIGNATURE";
		                $$->children.push_back($1);
		                $$->children.push_back($2);
		                $$->children.push_back($4);
                    }
                    |
                    TYPE ID LPAREN error RPAREN
                    {
                        $$ = new SyntNode();
                        $$->text = "sign_error";
                    }
                ;


ARG_LIST:               ARG_LIST_TAIL
                        {
//                            std::cout << "ARG_LIST<-ARG_LIST_TAIL" << std::endl;
                            $$ = $1;
                        }
                        |
                        {
//                            std::cout << "ARG_LIST<-eps" << std::endl;
                            SyntNode* node = new SyntNode();
                            node->text = "empty";
                            $$ = node;
                        }
                ;

ARG_LIST_TAIL:          ARG_LIST_TAIL COMMA ARG_DECL
                        {
//                            std::cout << "ARG_LIST_TAIL<-ARG_LIST_TAIL COMMA ARG_DECL" << std::endl;
                            SyntNode* node = new SyntNode();
                            node->text = "ARG_LIST";
	                        node->children.push_back($1);
	                        node->children.push_back($3);
                            $$ = node;
                        }
                        |
                        ARG_DECL
                        {
//                            std::cout << "ARG_LIST_TAIL<-ARG_DECL" << std::endl;
                            $$ = $1;
                        }
                ;

ARG_DECL:               TYPE ID
                        {
//                            std::cout << "ARG_DECL<-TYPE ID" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
	                        $$->children.push_back($2);
                        }
                        |
                        TYPE ID EQUAL RVALUE
                        {
//                            std::cout << "ARG_DECL<-TYPE ID EQUAL RVALUE" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "ARG_DECL";
	                        $$->children.push_back($1);
   	                        $$->children.push_back($2);
	                        $$->children.push_back($4);
                        }
                   ;

BLOCK:                  LBRACE STATEMENT_LIST RBRACE
                        {
//                            std::cout << "BLOCK<-LBRACE STATEMENT_LIST RBRACE" << std::endl;
                            if ($2 == NULL) {
                                SyntNode* node = new SyntNode();
                                node->text = "empty";
                                $$ = node;
                            } else {
                                $$ = $2;
                            }
                        }
                        |
                        LBRACE error RBRACE
                        {
                            $$ = new SyntNode();
                            $$->text = "error";
                        }
                ;

STATEMENT_LIST:         SINGLE_ST STATEMENT_LIST
                        {
//                            std::cout << "STATEMENT_LIST<-SINGLE_ST STATEMENT_LIST" << std::endl;
                            if ($1 == NULL) {
                                $$ = $2;
                            } else {
                                $$ = new SyntNode();
                                $$->text = "STATEMENT_LIST";
	                            $$->children.push_back($1);
                                if ($2 != NULL)
        	                        $$->children.push_back($2);
                            }
                        }
                        |
                        {
//                            std::cout << "STATEMENT_LIST<-eps" << std::endl;
                            $$ = NULL;
                        }
                ;

SINGLE_ST:              CONDITION_ST
                        {
//                            std::cout << "SINGLE_ST<-CONDITION_ST" << std::endl;
                            $$ = $1;
                        }
                        |
                        LOOP_ST
                        {
//                            std::cout << "SINGLE_ST<-LOOP_ST" << std::endl;
                            $$ = $1;
                        }
                        |
                        SIMPLE_ST SEMICOL
                        {
//                            std::cout << "SINGLE_ST<-SIMPLE_ST SEMICOL" << std::endl;
                            $$ = $1;
                        }
                        |
                        BLOCK
                        {
//                            std::cout << "SINGLE_ST<-BLOCK" << std::endl;
                            $$ = $1;
                        }
                        |
                        VAR_DECL
                        {
//                            std::cout << "SINGLE_ST<-VAR_DECL" << std::endl;
                            $$ = $1;
                        }
                ;
CONDITION_ST:           IF CONDITION SINGLE_ST ELSE SINGLE_ST
                        {
//                            std::cout << "CONDITION_ST<-IF LPAREN RVALUE RPAREN SINGLE_ST ELSE SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "if_else";
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
	                        $$->children.push_back($5);
                        }
                        |
                        IF CONDITION SINGLE_ST
                        {
//                            std::cout << "CONDITION_ST<-IF LPAREN RVALUE RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "short_if";
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }            
                        |
                        IF error
                        {
                            SyntNode* node = new SyntNode();
                            node->text = "error";
                            $$ = node;
                        }
                ;

CONDITION:      LPAREN RVALUE RPAREN
                {
                    $$ = $2;
                }
                |
                LPAREN error RPAREN
                {
                    SyntNode* node = new SyntNode();
                    node->text = "error";
                    $$ = node;
                }
                ;

LOOP_ST:                FOR FOR_ENTRY SINGLE_ST
                        {
//                            std::cout << "LOOP_ST<-FOR LPAREN FOR_INIT FOR_COND FOR_STEP RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "for_loop";
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        WHILE CONDITION SINGLE_ST
                        {
//                            std::cout << "LOOP_ST<-WHILE LPAREN RVALUE RPAREN SINGLE_ST" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "prefix_while";
	                        $$->children.push_back($2);
	                        $$->children.push_back($3);
                        }
                        |
                        DO BLOCK WHILE CONDITION SEMICOL
                        {
//                            std::cout << "LOOP_ST<-DO BLOCK WHILE LPAREN RVALUE RPAREN SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "postfix_while";
	                        $$->children.push_back($2);
                            $$->children.push_back($5);
                        }
                        |
                        DO error SEMICOL
                        {
                            $$ = new SyntNode();
                            $$->text = "while_error";
                        }
                ;

FOR_ENTRY:      LPAREN FOR_INIT FOR_COND FOR_STEP RPAREN
                {
                    $$ = new SyntNode();
                    $$->children.push_back($2);
                    $$->children.push_back($3);
                    $$->children.push_back($4);
                }
                |
                error
                {
                    $$ = new SyntNode();
                    $$->text = "error";
                }
                |
                error RPAREN
                {
                    $$ = new SyntNode();
                    $$->text = "error";
                }
            ;

SIMPLE_ST:              RVALUE
                        {
//                            std::cout << "SIMPLE_ST<-RVALUE" << std::endl;
                            $$ = $1;
                        }
                        |
                        RETURN RVALUE
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "return";
                            node->op = opRETURN;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        BREAK
                        {
//                            std::cout << "SIMPLE_ST<-BREAK" << std::endl;
                            $$ = $1;
                        }
                        |
                        CONTINUE
                        {
//                            std::cout << "INSTRUCTION<-CONTINUE" << std::endl;
                            $$ = $1;
                        }
                        |
                        {
                            $$ = NULL;
                        }
                ;

FOR_INIT:               VAR_DECL
                        {
//                            std::cout << "FOR_INIT<-VAR_DECL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT";
	                        $$->children.push_back($1);
                        }
                        |
                        RVALUE FOR_INIT_TAIL
                        {
//                            std::cout << "FOR_INIT<-RVALUE FOR_INIT_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT";
	                        $$->children.push_back($1);
                            if ($2 != NULL)
    	                        $$->children.push_back($2);
                        }
                        |
                        SEMICOL
                        {
//                            std::cout << "FOR_INIT<-SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "empty";
                        }
                ;

FOR_INIT_TAIL:          COMMA RVALUE FOR_INIT_TAIL
                        {
//                            std::cout << "FOR_INIT_TAIL<-COMMA RVALUE FOR_INIT_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_INIT_TAIL";
	                        $$->children.push_back($2);
                            if ($3 != NULL)
    	                        $$->children.push_back($3);
                        }
                        |
                        SEMICOL
                        {
//                            std::cout << "FOR_INIT_TAIL<-SEMICOL" << std::endl;
                            $$ = NULL;
                        }
                ;

FOR_COND:               RVALUE SEMICOL
                        {
//                            std::cout << "FOR_COND<-RVALUE SEMICOL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_COND";
	                        $$->children.push_back($1);
                        }
                        |
                        SEMICOL
                        {
                            $$ = new SyntNode();
                            $$->text = "FOR_COND";
                            ConstValueNode* node = new ConstValueNode();
                            node->text = "const_val";
                            node->type = BOOL;
                            node->value.boolean = true;
	                        $$->children.push_back(node);
                        }
                ;

FOR_STEP:               RVALUE FOR_STEP_TAIL
                        {
//                            std::cout << "FOR_STEP<-RVALUE FOR_STEP_TAIL" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "FOR_STEP";
	                        $$->children.push_back($1);
                            if ($2 != NULL)
    	                        $$->children.push_back($2);
                        }
                        |
                        {
//                            std::cout << "FOR_STEP<-eps" << std::endl;
                            $$ = new SyntNode();
                            $$->text = "empty";
                        }
                ;

FOR_STEP_TAIL:          COMMA RVALUE FOR_STEP_TAIL
                        {
//                            std::cout << "FOR_STEP_TAIL<-COMMA RVALUE FOR_STEP_TAIL" << std::endl;
                            $$ = new SyntNode();    
                            $$->text = "FOR_STEP_TAIL";
	                        $$->children.push_back($2);
                            if ($3 != NULL)
    	                        $$->children.push_back($3);
                        }
                        |
                        {
//                            std::cout << "FOR_STEP_TAIL<-eps" << std::endl;
                            $$ = NULL;
                        }
                        | 
                        error SEMICOL
                        {
                            $$ = new SyntNode();
                            $$->text = "error";                            
                        }
                ;                                               

RVALUE:          		LVALUE EQUAL RVALUE
                        {
//                            std::cout << "RVALUE<-LVALUE EQUAL RVALUE" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "assign";
                            node->op = opASSIGN;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        LOGIC_OR_EXPR
                        {
                            $$ = $1;
                        }
		        ;


LOGIC_OR_EXPR:          LOGIC_OR_EXPR LOGIC_OR_OP LOGIC_AND_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "||";
                            node->op = opL_OR;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        LOGIC_AND_EXPR
                        {
                            $$ = $1;
                        }
                ;

LOGIC_AND_EXPR:         LOGIC_AND_EXPR LOGIC_AND_OP BW_OR_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "&&";
                            node->op = opL_AND;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        BW_OR_EXPR
                        {
                            $$ = $1;
                        }
                ;

BW_OR_EXPR:             BW_OR_EXPR BW_OR_OP BW_XOR_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "|";
                            node->op = opB_OR;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        BW_XOR_EXPR
                        {
                            $$ = $1;
                        }
                ;

BW_XOR_EXPR:            BW_XOR_EXPR BW_XOR_OP BW_AND_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "^";
                            node->op = opB_XOR;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        BW_AND_EXPR
                        {
                            $$ = $1;
                        }
                ;

BW_AND_EXPR:            BW_AND_EXPR BW_AND_OP EQ_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "&";
                            node->op = opB_AND;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        EQ_EXPR
                        {
                            $$ = $1;
                        }
                ;

EQ_EXPR:                EQ_EXPR EQ_COMP_OP ORD_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "==";
                            node->op = opEQ;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        EQ_EXPR NE_COMP_OP ORD_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "!=";
                            node->op = opNE;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        ORD_EXPR
                        {
                            $$ = $1;
                        }
                ;

ORD_EXPR:               ORD_EXPR LT_COMP_OP SHIFT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "<";
                            node->op = opLT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        ORD_EXPR LE_COMP_OP SHIFT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "<=";
                            node->op = opLE;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        ORD_EXPR GT_COMP_OP SHIFT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = ">";
                            node->op = opGT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        ORD_EXPR GE_COMP_OP SHIFT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = ">=";
                            node->op = opGE;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        SHIFT_EXPR
                        {
                            $$ = $1;
                        }
                ;

SHIFT_EXPR:             SHIFT_EXPR LSHIFT_OP SUM_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "lshift";
                            node->op = opLSHIFT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        SHIFT_EXPR RSHIFT_OP SUM_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "rshift";
                            node->op = opRSHIFT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        SUM_EXPR
                        {
                            $$ = $1;
                        }
                ;

SUM_EXPR:               SUM_EXPR PLUS_OP MULT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "sum";
                            node->op = opSUM;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        SUM_EXPR MINUS_OP MULT_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "minus";
                            node->op = opMINUS;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        MULT_EXPR
                        {
//                            std::cout << "SUM_EXPR<-MULT_EXPR" << std::endl;
                            $$ = $1;
                        }
                ;

MULT_EXPR:              MULT_EXPR DIV_OP CAST_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "div";
                            node->op = opDIV;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        MULT_EXPR REM_OP CAST_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "rem";
                            node->op = opREM;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;

                        }
                        |
                        MULT_EXPR MULT_OP CAST_EXPR
                        {
//                            std::cout << "MULT_EXPR<-MULT_EXPR MULT_OP CAST_EXPR" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "mult";
                            node->op = opMULT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        CAST_EXPR
                        {
//                            std::cout << "MULT_EXPR<-CAST_EXPR" << std::endl;
                            $$ = $1;
                        }
                ;

CAST_EXPR:              LPAREN BASIC_TYPE RPAREN CAST_EXPR
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "cast";
                            node->op = opCAST;
                            node->left = $2;
                            node->right = $4;
                            $$ = node;
                        }
                        |
                        PLUS_OP CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "unary_plus";
                            node->op = opUPLUS;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        MINUS_OP CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "unary_minus";
                            node->op = opUMINUS;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        LOGIC_NOT CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "logic_not";
                            node->op = opLNOT;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        BW_NOT_OP CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "bw_not";
                            node->op = opBNOT;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        INCR_EXPR
                        {
                            $$ = $1;
                        }
                        |
                        INCR_OP CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "prefix_inc";
                            node->op = opPREFIX_INC;
                            node->operand = $2;
                            $$ = node;
                        }
                        |
                        DECR_OP CAST_EXPR
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "prefix_dec";
                            node->op = opPREFIX_DEC;
                            node->operand = $2;
                            $$ = node;
                        }
                ;

INCR_EXPR:              INCR_EXPR INCR_OP
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "postfix_inc";
                            node->op = opPOSTFIX_INC;
                            node->operand = $1;
                            $$ = node;
                        }
                        |
                        INCR_EXPR DECR_OP
                        {
                            UnaryOp* node = new UnaryOp();
                            node->text = "postfix_dec";
                            node->op = opPOSTFIX_DEC;
                            node->operand = $1;
                            $$ = node;
                        }
                        |
                        SIMPLE_EXPR
                        {
//                            std::cout << "INCR_EXPR<-SIMPLE_EXPR" << std::endl;
                            $$ = $1;
                        }
                ;

SIMPLE_EXPR:            LPAREN RVALUE RPAREN
                        {
                            $$ = $2;
                        }
                        |
                        ELEM_EXPR
                        {
//                            std::cout << "SIMPLE_EXPR <- ELEM_EXPR" << std::endl;
                            $$ = $1;
                        }
                        |
                        NUMBER
                        {
//                            std::cout << "SIMPLE_EXPR <- NUMBER" << std::endl;
                            $$ = new ConstValueNode($1);
                            delete $1;
                        }
                ;

FUNC_CALL:              ID LPAREN PARAM_LIST RPAREN
                        {
//                            std::cout << "FUNC_CALL<-ID LPAREN PARAM_LIST RPAREN" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "call";
                            node->op = opCALL;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                ;

PARAM_LIST:             RVALUE PARAM_LIST_TAIL
                        {
//                            std::cout << "PARAM_LIST<-RVALUE PARAM_LIST_TAIL" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "param";
                            node->op = opPARAM;
                            node->left = $1;
                            node->right = $2;
                            $$ = node;
                        }
                        |
                        {
                            $$ = NULL;
                        }
                ;
PARAM_LIST_TAIL:        COMMA RVALUE PARAM_LIST_TAIL
                        {
//                            std::cout << "PARAM_LIST_TAIL<-COMMA RVALUE PARAM_LIST_TAIL" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "param";
                            node->op = opPARAM;
                            node->left = $2;
                            node->right = $3;
                            $$ = node;
                        }
                        |
                        {
//                            std::cout << "PARAM_LIST_TAIL<-eps" << std::endl;
                            $$ = NULL;
                        }
                ;

ELEM_EXPR:              MEMB_ACCESS
                        {
                            $$ = $1;
                        }
                        |
                        METHOD_CALL
                        {
                            $$ = $1;
                        }
                        |
                        FUNC_CALL
                        {
                            $$ = $1;
                        }             
                ;

MEMB_ACCESS:            MEMB_ACCESS DOT ID
                        {
//                            std::cout << "MEMB_ACCESS<-DOT ID MEMB_ACCESS" << std::endl;
                            if ($3 == NULL) {
                                $$ = $1;
                            } else {
                                BynaryOp* node = new BynaryOp();
                                node->text = "dot";
                                node->op = opDOT;
                                node->left = $1;
                                node->right = $3;
                                $$ = node;
                            }
                        }
                        |
                        ID
                        {
                            $$ = $1;
                        }
                ;
METHOD_CALL:            MEMB_ACCESS DOT FUNC_CALL 
                        {
//                            std::cout << "MEMB_ACCESS<-DOT METHOD_CALL MEMB_ACCESS" << std::endl;
                            BynaryOp* node = new BynaryOp();
                            node->text = "call";
                            node->op = opCALL;
                            BynaryOp* call = dynamic_cast<BynaryOp*>($3);
                            node->left = call->left;
                            BynaryOp* args = new BynaryOp();
                            args->text = "param";
                            args->op = opPARAM;
                            node->right = args;
                            args->left = $1;
                            args->right = call->right;
                            $$ = node;
                        }
                        |
                        METHOD_CALL DOT FUNC_CALL
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "call";
                            node->op = opCALL;
                            BynaryOp* call = dynamic_cast<BynaryOp*>($3);
                            node->left = call->left;
                            BynaryOp* args = new BynaryOp();
                            args->text = "param";
                            args->op = opPARAM;
                            node->right = args;
                            args->left = $1;
                            args->right = call->right;
                            $$ = node;
                        }
                        |
                        METHOD_CALL DOT ID
                        {
                            BynaryOp* node = new BynaryOp();
                            node->text = "dot";
                            node->op = opDOT;
                            node->left = $1;
                            node->right = $3;
                            $$ = node;
                        }
                ;

LVALUE:             MEMB_ACCESS
                    {
//                        std::cout << "LVALUE<-LONG_NAME LVAL_ACCTAIL" << std::endl;
                        $$ = $1;
                    }
                ;

%%

void yyerror(const char* message) {
    ParserHelper::getInstance()->error_count[1]++;
    int cur_line = LexHelper::getInstance()->cur_line;
    std::stringstream ss;
    std::vector<std::string> exp_token;
    std::string cur_text = LexHelper::getInstance()->cur_text;
    ss.str(message);
    while (ss.good()) {
        std::string tmp;
        ss >> tmp;
        if (tmp == "expecting")
            break;
    }
    while (ss.good()) {
        std::string tmp;
        ss >> tmp;
        if (tmp != "or")
            exp_token.push_back(tmp);
    }
    std::cerr << "[Syntax error] at (" << cur_line;
    std::cerr << ", " << 
            LexHelper::getInstance()->cur_pos - cur_text.size() << "): ";
    std::cerr << "unexpected token ";
    std::cerr << ParserHelper::errorMessageForUnexpecedToken(cur_text);
    std::cerr << ", expecting ";
    for (size_t i = 0; i < exp_token.size(); ++i) {
        std::cerr << ParserHelper::convertBisonString(exp_token[i]);
        if (i < exp_token.size() - 1)
            std::cerr << ", ";
    }
    std::cerr << std::endl;
//	printf("%s\n", message);
}
