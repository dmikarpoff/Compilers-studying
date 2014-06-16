#ifndef _LEX_HELPER_H_
#define _LEX_HELPER_H_

#include <string>
#include <vector>
#include <set>

#include <grammar.hpp>
#include <SyntaxTree.h>

class LexHelper
{
public:
    static std::string tokenToString(int token);
    static LexHelper* getInstance();
    static void setToken(TokenNode* token);
    void reset();
    size_t cur_line, cur_pos;
    int cur_token;
    std::string cur_text;
    std::set<std::string> types;
private:
    LexHelper();
    ~LexHelper()
    {

    }

    static LexHelper* object;
};

#endif
