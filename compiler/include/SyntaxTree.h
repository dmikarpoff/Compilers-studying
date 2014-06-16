#ifndef _SYNTAX_TREE_H_
#define _SYNTAX_TREE_H_

#include <vector>
#include <string>
#include <cstdlib>

enum LangOperation {
    opDOT, opCALL, opPARAM, opPOSTFIX_DEC,
    opPOSTFIX_INC, opCAST, opUPLUS, opUMINUS,
    opLNOT, opBNOT, opPREFIX_INC, opPREFIX_DEC,
    opMULT, opREM, opDIV, opSUM, opMINUS,
    opRSHIFT, opLSHIFT, opLT, opLE, opGT,
    opGE, opEQ, opNE, opB_AND, opB_XOR,
    opB_OR, opL_AND, opL_OR, opASSIGN, opRETURN
};

union ValueHolder {
    long integer;
    double rational;
    bool boolean;
};

enum BasicType {
    BOOL,
    CHAR,
    INT,
    LONG,
    FLOAT,
    DOUBLE
};

class SuperNode {
public:
    SuperNode():
        text("")
    {

    }

    virtual ~SuperNode() { }
    std::string text;
};

class UnaryOp : public SuperNode {
public:
    SuperNode* operand;
    LangOperation op;
};

class BynaryOp : public SuperNode {
public:
    SuperNode* left, *right;
    LangOperation op;
};

class TokenNode : public SuperNode
{
public:
    TokenNode();

    size_t line, position;
    int token;

    virtual ~TokenNode() { }
};

class ConstValueNode : public SuperNode {
public:
    ConstValueNode():
        SuperNode() {}
    ConstValueNode(TokenNode* token);
    ValueHolder value;
    BasicType type;
};

class SyntNode : public SuperNode
{
public:
    SyntNode() {}
    std::vector<SuperNode*> children;
    virtual ~SyntNode();
};

class IDNode : public SyntNode {
public:
    std::string id;
    virtual ~IDNode() {}
};

#endif
