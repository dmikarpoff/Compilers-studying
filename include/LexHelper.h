#ifndef _LEX_HELPER_H_
#define _LEX_HELPER_H_

#include <string>
#include <vector>

class LexHelper
{
public:
    static std::string tokenToString(int token);
    static LexHelper* getInstance();
    void reset();
    size_t cur_line, cur_pos;
    std::vector<std::string> error_list;
private:
    LexHelper():
        cur_line(1),
        cur_pos(1)
    {

    }
    ~LexHelper()
    {

    }

    static LexHelper* object;
};

#endif
