#include <SyntaxTree.h>

TokenNode::TokenNode():
    SuperNode(),
    line(0),
    position(0),
    token(0)
{
}



SyntNode::~SyntNode()
{
    for (size_t i = 0; i < children.size(); ++i)
        delete children[i];
}
