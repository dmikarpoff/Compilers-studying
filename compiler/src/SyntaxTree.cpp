#include <SyntaxTree.h>
#include <sstream>

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

ConstValueNode::ConstValueNode(TokenNode* token):
    SuperNode() {
    text = "const_val";
    if (token->text == "true") {
        type = BOOL;
        value.boolean = true;
    } else if (token->text == "false") {
        type = BOOL;
        value.boolean = false;
    } else {
        std::stringstream ss;
        ss.str(token->text);
        if (token->text.find(".") != token->text.size() ||
                token->text.find("E") != token->text.size() ||
                token->text.find("e") != token->text.size()) {
            type = DOUBLE;
            ss >> value.rational;
        } else {
            type = LONG;
            ss >> value.integer;
        }
    }
}
