#ifndef _SYNTAX_TREE_H_
#define _SYNTAX_TREE_H_

#include <vector>
#include <string>
#include <cstdlib>

class SuperNode
{
public:
    SuperNode():
        parent(NULL),
        text("EMPTY")
    {

    }

    SuperNode* getParent()
    {
        return parent;
    }

    const SuperNode* getParent() const
    {
        return parent;
    }

    void setParent(SuperNode* node)
    {
        parent = node;
    }

    virtual ~SuperNode() { }
    std::string text;
private:
    SuperNode* parent;
};

class TokenNode : public SuperNode
{
public:
    TokenNode();

    size_t line, position;
    int token;

    virtual ~TokenNode() { }
};

class StringToken : public TokenNode {
public:
    std::string str;
};

class SyntNode : public SuperNode
{
public:
    SyntNode() {}
    std::vector<SuperNode*> children;
    ~SyntNode();
};

#endif
